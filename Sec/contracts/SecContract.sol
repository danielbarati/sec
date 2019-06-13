pragma solidity >=0.4.25 <0.6.0;
//pragma experimental ABIEncoderV2;

contract SecContract {
    struct Owner {
        address payable addr;
        uint account;
        bytes32[] encWhisperKeys;
        bool hasSigned;
    }

    struct Storer {
        address addr;
        uint account;
        bytes pubKey;
        bytes32[] certHashes;
        bool hasSigned;
        bool[] correctlyAnswered;
    }

    struct Peer {
        uint deposit;
        bool hasFrozenDeposit;
        bytes pubKey;
        bytes32 certHash;
        bytes32 encWhisperKey;
        uint startWork;
        uint endWork;
        uint remuneration;
        bool hasVerifiedCert;
        bool hasPassedVerification;
    }

    uint public rc = 10;
    uint public rs1 = 100;
    uint public alpha = 1;
    uint public ds;

    Owner public o;  // Sender
    Storer public s;  // Receiver

    mapping (address => Peer) public p; // Peers
    address[] public pIndices;
    mapping (uint => address[]) public paths;
    address[] public selectedPs;
    uint public _numPaths;
    uint[] public _pathEndings;
    bytes32[] public _challengeHashes;
    bytes32[] public _answerHashes;
    address[] public faulties;
    bool[] public terminated;

    modifier onlyO {
        require(
            msg.sender == o.addr,
            "Only the Sender can call this function."
        );
        _;
    }

    modifier onlyS {
        require(
            msg.sender == s.addr,
            "Only the Recipient can call this function."
        );
        _;
    }

    modifier onlyP {
        bool isSelectedP = false;
        for (uint i = 0; i < selectedPs.length; i++) {
            if (msg.sender == selectedPs[i]) {
                isSelectedP = true;
                break;
            }
        }
        require(
            isSelectedP,
            "Only Peers can call this function."
        );
        _;
    }

    modifier onlyPS {
        bool isSelectedP = false;
        for (uint i = 0; i < selectedPs.length; i++) {
            if (msg.sender == selectedPs[i]) {
                isSelectedP = true;
                break;
            }
        }
        require(
            isSelectedP || msg.sender == s.addr,
            "Only the Recipient or Peers can call this function."
        );
        _;
    }

    constructor() public {
       return;
    }

    // Function to recover the funds on the contract
    function kill() public onlyS {
        selfdestruct(msg.sender);
    }

    // Register component
    function newPeer(bytes calldata pubKey, uint start, uint end) external payable {
        if (peerExists(msg.sender))
            revert("Peer is already registered.");
        p[msg.sender] = Peer(msg.value, false, pubKey, bytes32(0), bytes32(0), start, end, 0, false, false);
        pIndices.push(msg.sender);
    }

    function updateBalance() external payable returns (uint) {
        if (p[msg.sender].hasFrozenDeposit) {
            revert("Peer is partaking in an ongoing process.");
        } else if (msg.value == 0) {
            msg.sender.transfer(p[msg.sender].deposit);
            p[msg.sender].deposit = 0;
        } else {
            p[msg.sender].deposit += msg.value;
        }
    }

    function updateWindow(uint start, uint end) public {
        if (start < now || end < now || end <= start)
            revert("Start and end times must be later than the current time.");
        //if (p[msg.sender].hasFrozenDeposit)
        //    revert("Peer is partaking in an ongoing process.");
        p[msg.sender].startWork = start;
        p[msg.sender].endWork = end;
    }

    function updatePubKey(bytes memory pubKey) public {
        p[msg.sender].pubKey = pubKey;
    }


    // Setup component
    function ownerSign(address storerAddr) public {
        // Sender should sign the contract.
        o = Owner(msg.sender, 0, new bytes32[](0), true);
        s.addr = storerAddr;
    }

    function storerSign(bytes memory pubKey) public {
        if (msg.sender == s.addr) {
            s.pubKey = pubKey;
            s.hasSigned = true;
        }
    }

    /** @dev Lets owner set up the system.
      * @param selectedPeers Selected peers in all paths.
      * @param numPaths Number of paths.
      * @param pathEndings For all paths, which index in selectedPeers that is the last peer for that path. E.g. If 3 then 2 is the last peer in the path.
      * @param remuneration Total remuneration to the peers in all paths.
      * @param deposit The required deposit amount that is required of the selected peers.
      * @return bool Setup success.
      */
    function setup(
        address[] memory selectedPeers,
        uint numPaths,
        uint[] memory pathEndings,
        uint remuneration,
        uint deposit) public payable onlyO returns (bool setupIsSuccessful) {
        require(o.hasSigned && s.hasSigned, "Both owner and storer must sign.");
        require(msg.value >= remuneration+(deposit*numPaths), "Payment is insufficient relative to inputted values.");
        selectedPs = selectedPeers;
        _numPaths = numPaths;
        _pathEndings = pathEndings;
        ds = deposit;
        for (uint i = 0; i < numPaths; i++) {
            uint start = 0;
            if (i > 0) start = pathEndings[i-1];
            for (uint j = start; j < pathEndings[i]; j++) {
                paths[i].push(selectedPs[j]);
            }
        }
        bool selectedPMeetRequirements = true;
        for (uint i = 0; i < selectedPs.length; i++) {
            if (p[selectedPs[i]].deposit < deposit || p[selectedPs[i]].hasFrozenDeposit) {
                selectedPMeetRequirements = false;
            }
        }

        // Check if owner has sufficient account balance and that selected peers meet the requirements
        if (!isOwnerPaymentSufficient(deposit, msg.value) || !selectedPMeetRequirements) {
            // reject setup
            o.addr.transfer(msg.value);
            return false;
        }

        // Mark all paths as not terminated.
        for (uint i = 0; i < numPaths; i++) {
            terminated.push(false);
            s.correctlyAnswered.push(false);
        }

        // Freeze deposits of peers, and approve setup
        for (uint i = 0; i < selectedPs.length; i++) {
            p[selectedPs[i]].hasFrozenDeposit = true;
        }
        return true;
    }


    // Enforce component
    /** @dev Lets owner submit necessary data
      * @param certHashes Hashes of the certificates of the peers in the same order of selectedPs.
      * @param storerCertHashes Hashes of the certificates of data storer.
      * @param challengeHashes Hashes of the challenges in each path (only encrypted by the recipient’s public key)
      * @param answerHashes Hashes of the answers to the challenges in each path. For verification of storer's answer.
      * @param encWhisperKeys Whisper keys of Owner for each path. Encrypted by the public key of each subsequent peer.
      */
    function setProps(
       bytes32[] memory certHashes,
       bytes32[] memory storerCertHashes,
       bytes32[] memory challengeHashes,
       bytes32[] memory answerHashes,
       bytes32[] memory encWhisperKeys) public onlyO {
        s.certHashes = storerCertHashes;
        for (uint i = 0; i < certHashes.length; i++) {
            p[selectedPs[i]].certHash = certHashes[i];
        }

        _challengeHashes = challengeHashes;
        _answerHashes = answerHashes;
        o.encWhisperKeys = encWhisperKeys;
        return;
    }

    function verifyCert(bytes memory certificate, uint path) public onlyPS returns (bool isVerified){
        bytes32 certHash = keccak256(certificate);

        if (p[msg.sender].certHash == certHash) {
            p[msg.sender].hasVerifiedCert = true;
            return true;
        } else if (msg.sender == s.addr && s.certHashes[path] == certHash) {
            return true;
        }
        return false;
    }

    function setWhisperKey(bytes32 encWhisperKey) public onlyP {
        p[msg.sender].encWhisperKey = encWhisperKey;
    }

    function verification(uint path) public onlyP returns (bool) {  // Invoked by Ps and s to do verification
        require(!terminated[path], "Path is already terminated.");
        if (p[msg.sender].hasVerifiedCert && p[msg.sender].encWhisperKey != bytes32(0)) {
            p[msg.sender].hasPassedVerification = true;
            return true;
        }

        faulties.push(msg.sender);
        unfreezeDeposits(paths[path], faulties);
        uint remain = remunerationPayout(paths[path], faulties);
        o.addr.transfer(remain + 2*ds);
        terminated[path] = true;
        return false;
    }

    function submitAnswer(bytes memory answer, uint path) public onlyS returns (bool) {
        require(!terminated[path], "Path is already terminated.");
        if (keccak256(answer) == _answerHashes[path]) {
            s.correctlyAnswered[path] = true;
        } else {
            s.correctlyAnswered[path] = false;
        }
        unfreezeDeposits(paths[path], faulties);
        uint remain = remunerationPayout(paths[path], faulties);
        o.addr.transfer(remain + ds);
        terminated[path] = true;
        return s.correctlyAnswered[path];
    }


    // Report component
    function releaseReport(uint path, bytes memory challenge) public onlyS {
        require(!terminated[path], "Path is already terminated.");
        require(p[paths[path][paths[path].length - 1]].endWork > now, "Proof not delivered before challenge release time.");
        bytes32 challengeHash = keccak256(challenge);
        address faultyPeer;
        if (challengeHash == _challengeHashes[path]) {
            faulties.push(faultyPeer);
            unfreezeDeposits(paths[path], faulties);
            uint remain = remunerationPayout(paths[path], faulties);
            msg.sender.transfer(ds);
            o.addr.transfer(ds + remain);
            terminated[path] = true;
        }
    }

    function dropReport(uint path) public onlyPS {
        require(!terminated[path], "Path is already terminated.");
        address faultyPeer;
        if (msg.sender == s.addr) {
            require(p[paths[path][paths[path].length]].startWork < now, "Last peer has not yet finished its working window.");
            faultyPeer = paths[path][paths[path].length - 1];
            faulties.push(faultyPeer);
        } else {
            require(p[msg.sender].startWork < now, "Invoker has not started its working window.");
            if (msg.sender != paths[path][0]) {
                for (uint i = 0; i < paths[path].length; i++) {
                    if (paths[path][i] == msg.sender) {
                        faultyPeer = paths[path][i-1];
                        break;
                    }
                }
                faulties.push(faultyPeer);
            }
            faulties.push(msg.sender);
            msg.sender.transfer(ds/2);
        }
        unfreezeDeposits(paths[path], faulties);
        remunerationPayout(paths[path], faulties);
        terminated[path] = true;
    }

    // Getters
    function getPeers() public view returns (address[] memory) {
        /** NOTE: from Solidity docs, Solidity in Depth->Contracts->Get Functions:
        * "If you have a public state variable of array type, then you can only
        * retrieve single elements of the array via the generated getter function.
        * This mechanism exists to avoid high gas costs when returning an entire
        * array. You can use arguments to specify which individual element to return,
        * for example data(0). If you want to return an entire array in one call, then
        * you need to write a function."
        */
        return pIndices;
    }

    function getSelectedPeers() public view returns (address[] memory) {
        return selectedPs;
    }

    // Helper functions
    function peerExists(address addr) private view returns (bool) {
        bool exists = false;
        for (uint i = 0; i < pIndices.length; i++) {
            if (pIndices[i] == addr) {
                exists = true;
            }
        }
        return exists;
    }

    /** @dev Calculates and sets remuneration for every peer in each path and checks if totPayment by owner is correct.
      * @param deposit The deposit required by participants.
      * @param totPayment Total payment of data owner for setup of service.
      */
    function isOwnerPaymentSufficient(uint deposit, uint totPayment) private returns (bool) {
        uint calculatedTotRem = 0;
        for (uint i = 0; i < _numPaths; i++) {
            for (uint j = 0; j < paths[i].length; j++) {
                uint workingWindow = (p[paths[i][j]].endWork - p[paths[i][j]].startWork)/3600;
                uint r = rc + workingWindow*(2*rs1 + alpha*(workingWindow - 1))/2;
                p[paths[i][j]].remuneration = r;
                calculatedTotRem += r;
            }
        }
        if (totPayment >= calculatedTotRem + _numPaths*deposit) {
            return true;
        }
        return false;
    }

    function unfreezeDeposits(address[] memory path, address[] memory except) private {
        for (uint i = 0; i < path.length; i++) {
            bool isException = false;
            for (uint j = 0; j < except.length; j++) {
                if (path[i] == except[j]) isException = true;
            }
            if (!isException) {
                p[path[i]].hasFrozenDeposit = false;
            }
        }
    }

    function remunerationPayout(address[] memory path, address[] memory except) private returns (uint) {
        for (uint i = 0; i < path.length; i++) {
            bool isException = false;
            for (uint j = 0; j < except.length; j++) {
                if (path[i] == except[j]) isException = true;
            }
            if (!isException) {
                address payable payableAddr = address(uint160(path[i]));
                payableAddr.transfer(p[path[i]].remuneration);
            }
        }
        uint remain = 0;
        for (uint i = 0; i < except.length; i++) {
            remain += p[except[i]].remuneration;
        }
        return remain;
    }
}