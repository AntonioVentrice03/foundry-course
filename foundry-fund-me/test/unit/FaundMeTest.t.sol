//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
contract FundMeTest is Test{
    FundMe fundme;
    address USER= makeAddr("user");
    uint256 constant SEND_VALUE=0.1 ether;
    uint256 constant STARTING_BALANCE= 10 ether;
    uint256 constant GAS_PRICE=1;
    function setUp() external{
        //fundme=new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe=new DeployFundMe();
        fundme=deployFundMe.run();
        //dobbiamo associare al nostro fake user un po di fake balance altrimenti non potrà avere abbastanza gas per la transazione
        vm.deal(USER,STARTING_BALANCE);
    }
    function testMinimumDollarIsFive() public{
       assertEq(fundme.MINIMUM_USD(),5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundme.getOwner(),msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public{
        uint256 version= fundme.getVersion();
        console.log(version);
        assertEq(version,4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();// hey, the next line should revert!
        fundme.fund();//non inviamo valore quindi fallisce 
    }
    function  testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);// la prossima transazione sarà eseguita da user.
        fundme.fund{value:SEND_VALUE}(); //adesso iniviamo valore
        //uint256 amountFunded= fundme.getAddressToAmountFunded(address(this)); //fuunziona ma potrebbe essere confusionario
        uint256 amountFunded= fundme.getAddressToAmountFunded(USER);
        assertEq(amountFunded,SEND_VALUE);
    } 
    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundme.fund{value:SEND_VALUE}();
        address funder = fundme.getFunder(0);
        assertEq(USER,funder);
    }

    modifier funded(){
        vm.prank(USER);
        fundme.fund{value:SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw()public funded{
        //inserisce il codice della modifier direttamente qua senza doverlo ripetere rimane piu pulito
        vm.prank(USER);
        vm.expectRevert();
        //ora ci aspettiamo un revert 
        fundme.withdraw();
    }
    //testiamo che la withdraw con un solo funder
    function testWithDraWithASinglgeFunder() public funded {
        //Arrange
        uint256 startingOwnerFaund=fundme.getOwner().balance;
        uint256 startingFundMeBalance=address(fundme).balance;
        //Act
        vm.txGasPrice(GAS_PRICE);//per settare il gas della transazione
        vm.prank(fundme.getOwner()); //fingiamo di essere l'owner
        fundme.withdraw();
        //Assert
        uint256 endingOwnerBalance=fundme.getOwner().balance;
        uint256 endingFundMeBalance=address(fundme).balance;
        assertEq(endingFundMeBalance,0);
        assertEq(startingFundMeBalance+startingOwnerFaund,endingOwnerBalance);
    }
    function testWithDrawFromMultipleFunders() public funded{
        //per creare degli address partendo da dei numeri dovremmo fare così
        uint160 funders=10;
        uint160 startingFundersIndex=1;

        for(uint160 i=startingFundersIndex;i<funders;i++){
            //settare un prank user con degli eath
            //come se fossero inviati piu eth da diversi utenti senza effettivamente crearli
            hoax(address(i),SEND_VALUE);
            fundme.fund{value:SEND_VALUE}();
        }
        uint256 startingOwnerFaund=fundme.getOwner().balance;
        uint256 startingFundMeBalance=address(fundme).balance;
        //act
        vm.prank(fundme.getOwner()); //fingiamo di essere l'owner
        fundme.withdraw();
        //assert 
        assert(address(fundme).balance==0);
        //ma i balance non dovrebbero essere diversi poichè abbiamo speso del gas?
        assertEq(startingFundMeBalance+startingOwnerFaund,fundme.getOwner().balance);
    }
    function testWithDrawFromMultipleFundersCheaper() public funded{
        //per creare degli address partendo da dei numeri dovremmo fare così
        uint160 funders=10;
        uint160 startingFundersIndex=1;

        for(uint160 i=startingFundersIndex;i<funders;i++){
            //settare un prank user con degli eath
            //come se fossero inviati piu eth da diversi utenti senza effettivamente crearli
            hoax(address(i),SEND_VALUE);
            fundme.fund{value:SEND_VALUE}();
        }
        uint256 startingOwnerFaund=fundme.getOwner().balance;
        uint256 startingFundMeBalance=address(fundme).balance;
        //act
        vm.prank(fundme.getOwner()); //fingiamo di essere l'owner
        fundme.cheaperWithdraw();
        //assert 
        assert(address(fundme).balance==0);
        //ma i balance non dovrebbero essere diversi poichè abbiamo speso del gas?
        assertEq(startingFundMeBalance+startingOwnerFaund,fundme.getOwner().balance);



    }
}