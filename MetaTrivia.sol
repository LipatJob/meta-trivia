// SPDX-License-Identifier: MIT
// compiler version must be greater than or equal to 0.8.17 and less than 0.9.0
pragma solidity ^0.8.17;

contract MetaTrivia {
    struct Trivia {
        string question;
        bytes32 questionHash;
        bytes32 answerHash;
        bool isSolved;
        address answerer;
    }

    mapping(bytes32 => Trivia) public trivias;
    mapping(address => uint) public points;

    uint constant CREATE_TRIVIA_POINTS = 10;
    uint constant ANSWER_TRIVIA_POINTS = 20;

    function createTrivia(
        string memory question,
        string memory answer
    ) public returns (bytes32) {
        require(!compareTwoStrings(question, ""), "Question must not be empty");
        require(!compareTwoStrings(answer, ""), "Answer must not be empty");

        bytes32 questionHash = getHash(question);
        bytes32 answerHash = getHash(answer);
        if (trivias[questionHash].questionHash == questionHash) {
            revert("Question must be unique");
        }

        trivias[questionHash] = Trivia({
            question: question,
            questionHash: questionHash,
            answerHash: answerHash,
            isSolved: false,
            answerer: address(0)
        });
        assert(msg.sender != address(0));
        points[msg.sender] += CREATE_TRIVIA_POINTS;
        return questionHash;
    }

    function answerTrivia(
        bytes32 questionHash,
        string memory answer
    ) public returns (bool) {
        bytes32 givenAnswerHash = getHash(answer);
        bytes32 correctAnswerHash = trivias[questionHash].answerHash;
        if (givenAnswerHash == correctAnswerHash) {
            assert(msg.sender != address(0));

            Trivia storage targetTrivia = trivias[questionHash];
            targetTrivia.answerer = msg.sender;
            targetTrivia.isSolved = true;

            points[msg.sender] += ANSWER_TRIVIA_POINTS;
            return true;
        }
        return false;
    }

    function getTrivia(
        bytes32 questionHash
    ) public view returns (Trivia memory) {
        return trivias[questionHash];
    }

    function getBytes(bytes32 questionHash) public pure returns (bytes32) {
        return questionHash;
    }

    function getPoints() public view returns (uint) {
        return points[msg.sender];
    }

    function getHash(string memory value) private pure returns (bytes32) {
        return keccak256(abi.encode(value));
    }

    function compareTwoStrings(
        string memory s1,
        string memory s2
    ) public pure returns (bool) {
        return
            keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
    }
}
