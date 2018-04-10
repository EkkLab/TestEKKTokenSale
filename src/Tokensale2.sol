pragma solidity ^0.4.21;
import "ds-auth/auth.sol";
import "ds-exec/exec.sol";
import "ds-math/math.sol";

import "ds-token/token.sol";

contract Tokensale2 is DSAuth, DSExec, DSMath {
  address public beneficiary;
  uint public fundingGoal;
  uint public amountRaised;
  uint public deadline;
  uint256 public price;
  DSToken public tokenReward;
  uint public bundleSize;
  uint256 public totalSupply;

  mapping(address => uint256) public balanceOf;
  bool fundingGoalReached = false;
  bool crowdsaleClosed = false;

  event GoalReached(address recipient, uint totalAmountRaised);
  event FundTransfer(address backer, uint amount, bool isContribution);

  /**
  * Constructor function
  *
  * Setup the owner
  */
  function Tokensale2(
    address ifSuccessfulSendTo,
    uint fundingGoalInEthers,
    uint durationInMinutes,
    uint256 CostOfEachToken,
    uint minimalBundleSize,
    uint256 _totalSupply
    ) public{
      beneficiary = ifSuccessfulSendTo;
      fundingGoal = fundingGoalInEthers * 1 ether;
      deadline = now + durationInMinutes * 1 minutes;
      price = CostOfEachToken;
      totalSupply = _totalSupply * 1 ether;
      bundleSize = minimalBundleSize;
    }

    function initialize(DSToken ekkToken) auth {
      assert(address(tokenReward) == address(0));
      assert(ekkToken.owner() == address(this));
      //assert(ekkToken.authority() == DSAuthority(0));
      assert(ekkToken.totalSupply() == 0);

      tokenReward = ekkToken;
      tokenReward.mint(totalSupply);
    }

    /**
    * Fallback function
    *
    * The function without name is the default function that is called whenever anyone sends funds to a contract
    */
    function () payable public{
        require(!crowdsaleClosed);
        require((msg.value / price)  > bundleSize );
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        tokenReward.push(msg.sender, amount / price);
        emit FundTransfer(msg.sender, amount, true);
    }

    modifier afterDeadline() { if (now >= deadline) _; }

    /**
    * Check if goal was reached
    *
    * Checks if the goal or time limit has been reached and ends the campaign
    */
    function checkGoalReached() afterDeadline public{
      if (amountRaised >= fundingGoal){
        fundingGoalReached = true;
        emit GoalReached(beneficiary, amountRaised);
      }
      crowdsaleClosed = true;
    }


    /**
    * Withdraw the funds
    *
    * Checks to see if goal or time limit has been reached, and if so, and the funding goal was reached,
    * sends the entire amount to the beneficiary. If goal was not reached, each contributor can withdraw
    * the amount they contributed.
    */
    function safeWithdrawal() afterDeadline public{
      if (!fundingGoalReached) {
        uint amount = balanceOf[msg.sender];
        balanceOf[msg.sender] = 0;
        if (amount > 0) {
          if (msg.sender.send(amount)) {
            emit FundTransfer(msg.sender, amount, false);
            } else {
              balanceOf[msg.sender] = amount;
            }
          }
        }

        if (fundingGoalReached && beneficiary == msg.sender) {
          if (beneficiary.send(amountRaised)) {
            emit FundTransfer(beneficiary, amountRaised, false);
            } else {
              //If we fail to send the funds to beneficiary, unlock funders balance
              fundingGoalReached = false;
            }
          }
        }
      }
