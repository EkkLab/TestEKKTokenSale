pragma solidity ^0.4.21;
import "ds-auth/auth.sol";
import "ds-exec/exec.sol";
import "ds-math/math.sol";

import "ds-token/token.sol";

contract EkkTokenSale is DSAuth, DSExec, DSMath {
  address public beneficiary;
  uint public fundingGoal;
  uint public amountRaised;
  uint public deadline;
  uint256 public price;
  DSToken public tokenReward;
  uint public bundleSize;
  uint256 public totalSupply;
  uint     public  startTime;
  uint public bonusRate1; //all bonus rates are for lower rung(<200) and has to be specified as whole numbers, like 30 represents 30 percent.
  uint public bonusRate2;
  uint public bonusRate3;

  mapping(address => uint256) public balanceOf;
  bool fundingGoalReached = false;
  bool crowdsaleClosed = false;

  event GoalReached(address recipient, uint totalAmountRaised);

  event FundTransfer(address backer, uint amount, bool isContribution);

  event ChangedTokenOwner(address newOwner);
  event LogFreeze();
  event LogUnFreeze();

  /**
  * Constructor function
  *
  * Setup the owner
  */
  function EkkTokenSale(
    address ifSuccessfulSendTo,
    uint fundingGoalInEthers,
    uint durationInMinutes,
    uint256 CostOfEachToken,
    uint minimalBundleSize,
    uint256 _totalSupply,
    uint _bonusRate1,
    uint _bonusRate2,
    uint _bonusRate3
    ) public{
      beneficiary = ifSuccessfulSendTo;
      fundingGoal = fundingGoalInEthers * 1 ether;
      deadline = now + durationInMinutes * 1 minutes;
      price = CostOfEachToken;
      totalSupply = _totalSupply * 1 ether;
      bundleSize = minimalBundleSize;
      startTime = now;
      bonusRate1 = _bonusRate1;
      bonusRate2 = _bonusRate2;
      bonusRate3 = _bonusRate3;
    }

    function initialize(DSToken ekkToken) auth {
      assert(address(tokenReward) == address(0));
      assert(ekkToken.owner() == address(this));
      //assert(ekkToken.authority() == DSAuthority(0));
      assert(ekkToken.totalSupply() == 0);
      tokenReward = ekkToken;
      tokenReward.mint(totalSupply);
    }
    /* to be called after sale closed and all funds are taken cared for(either
    moved to benificiary or reverted) */

    function resetTokenOwner(address _NewContract) auth {
      require(!crowdsaleClosed);
      require(address(this).balance == 0);
      tokenReward.setOwner(_NewContract);
      emit ChangedTokenOwner(_NewContract);
    }

    /**
    * Fallback function
    *
    * The function without name is the default function that is called whenever anyone sends funds to a contract
    */
    function () payable public{
      require(!crowdsaleClosed);
      require((msg.value / price)  > bundleSize );
      uint bonus = 0;
      uint amount = msg.value;
      balanceOf[msg.sender] += amount;
      amountRaised += amount;
      uint bonusFactor = 1;
      uint totalReward;
      if (msg.value > 200 ether) {
        bonusFactor = 2;
      }
      if (now < startTime + 2 days ) {
        bonus = (amount/price) * bonusRate1 * bonusFactor * 0.01 ether;
      }
      else if ( (now > startTime + 2 days) && (now < startTime + 7 days)) {
        bonus = (amount/price) * bonusRate2* bonusFactor * 0.01 ether;
      }
      else if ((now > startTime + 7 days) && (now < startTime + 14 days)) {
        bonus = (amount/price) * bonusRate3 *bonusFactor* 0.01 ether;
      }

      totalReward = (amount/price) + bonus;
      tokenReward.push(msg.sender, totalReward);
      emit FundTransfer(msg.sender, totalReward, true);
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

        function freeze() auth{
          tokenReward.stop();
          emit LogFreeze();
        }
        function unfreeze() auth{
          tokenReward.start();
          emit LogUnFreeze();
        }
      }
