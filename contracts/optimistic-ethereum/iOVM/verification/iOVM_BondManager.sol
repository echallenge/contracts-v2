// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.5.0 <0.8.0;

interface ERC20 {
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
}

/// All the errors which may be encountered on the bond manager
library Errors {
    string constant ERC20_ERR = "BondManager: Could not post bond";
    string constant LOW_VALUE = "BondManager: New collateral value must be greater than the previous one";
    string constant HIGH_VALUE = "BondManager: New collateral value cannot be more than 5x of the previous one";
    string constant ALREADY_FINALIZED = "BondManager: Fraud proof for this pre-state root has already been finalized";
    string constant SLASHED = "BondManager: Cannot finalize withdrawal, you probably got slashed";
    string constant WRONG_STATE = "BondManager: Wrong bond state for proposer";
    string constant CANNOT_CLAIM = "BondManager: Cannot claim yet. Dispute must be finalized first";

    string constant WITHDRAWAL_PENDING = "BondManager: Withdrawal already pending";
    string constant TOO_EARLY = "BondManager: Too early to finalize your withdrawal";

    string constant ONLY_OWNER = "BondManager: Only the contract's owner can call this function";
    string constant ONLY_TRANSITIONER = "BondManager: Only the transitioner for this pre-state root may call this function";
    string constant ONLY_FRAUD_VERIFIER = "BondManager: Only the fraud verifier may call this function";
    string constant ONLY_STATE_COMMITMENT_CHAIN = "BondManager: Only the state commitment chain may call this function";
}

/**
 * @title iOVM_BondManager
 */
interface iOVM_BondManager {

    /*******************
     * Data Structures *
     *******************/

    /// The lifecycle of a proposer's bond
    enum State {
        // Before depositing or after getting slashed, a user is uncollateralized
        NOT_COLLATERALIZED,
        // After depositing, a user is collateralized
        COLLATERALIZED,
        // After a user has initiated a withdrawal
        WITHDRAWING
    }

    /// A bond posted by a proposer
    struct Bond {
        // The user's state
        State state;
        // The timestamp at which a proposer issued their withdrawal request
        uint32 withdrawalTimestamp;
    }

    // Per pre-state root, store the number of state provisions that were made
    // and how many of these calls were made by each user. Payouts will then be
    // claimed by users proportionally for that dispute.
    struct Rewards {
        // Flag to check if rewards for a fraud proof are claimable
        bool canClaim;
        // Total number of `recordGasSpent` calls made
        uint256 total;
        // The gas spent by each user to provide witness data. The sum of all 
        // values inside this map MUST be equal to the value of `total`
        mapping(address => uint256) gasSpent;
    }


    /********************
     * Public Functions *
     ********************/
    
    function recordGasSpent(
        bytes32 _preStateRoot,
        address _who,
        uint256 _gasSpent
    ) external;

    function finalize(
        bytes32 _preStateRoot,
        uint256 _batchIndex,
        address _publisher,
        uint256 _timestamp
    ) external;

    function deposit(
        uint256 _amount
    ) external;

    function startWithdrawal() external;

    function finalizeWithdrawal() external;

    function claim(
        bytes32 _preStateRoot
    ) external;

    function setRequiredCollateral(
        uint256 _newValue
    ) external;

    function isCollateralized(
        address _who
    ) external view returns (bool);

    function getGasSpent(
        bytes32 _preStateRoot,
        address _who
    ) external view returns (uint256);
}
