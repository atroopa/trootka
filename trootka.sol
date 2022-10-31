pragma solidity ^0.4.26;












contract trootka{

    struct MemberInfo{
        uint userID;
        address referrer;
    }

    struct MatrixInfo{
        bool isActive;
        uint enterred;
        address[] referrals;
        uint totalcyle;
    }

    //mapping key => value pair
    mapping (uint => address) public userIds;
    mapping (address => MemberInfo) memberInfos;
    mapping (uint => mapping(uint => MatrixInfo)) matrixInfos;
    mapping (address => uint) public balance;
    mapping (uint => uint) public matrixTransaction;

    uint256 public totalTransactions;
    address[] public members;
    address public owner;
    uint public lastID = 2;

    constructor() public {
        owner = msg.sender; 
        userIds[1] = owner;
        MemberInfo storage _memberInfo = memberInfos[owner];
        _memberInfo.userID = 1;
        MatrixInfo storage _newMatrixInfo = matrixInfos[1][1];
        _newMatrixInfo.isActive = true;

    }

    function registration (address uplineAddress) external payable{
        require(msg.value >= 0.5 ether, "registration starts at 0.05");

        uint packageLvl = getPackageLevel(msg.value);

        //check if the address already exist
        uint memberId = getUserId(msg.sender);
        bool memberHasPackage = matrixInfos[memberId][packageLvl].isActive;
        require(!memberHasPackage, "member already registered to this Level");

        // check upline if valid
        uint uplineUserId = getUserId(msg.sender);
        require(uplineUserId > 0 , "upline address not found.");

        // check if upline has same package
        bool uplineHasPackage = matrixInfos[uplineUserId][packageLvl].isActive;
        require(uplineHasPackage, "upline not registered to this level");

        if(memberId == 0){
            memberId = lastID++;
            MemberInfo storage _memberInfo = memberInfos[msg.sender];
            _memberInfo.referrer = uplineAddress;
            _memberInfo.userID = memberId;
            userIds[memberId] = msg.sender;
        }
        // create new member matrix details
        MatrixInfo storage _newMatrixInfo = matrixInfos[memberId][packageLvl];
        _uplineMatrixInfo.isActive = true;

        MatrixInfo storage _uplineMatrixInfo = matrixInfos[uplineUserId][packageLvl];
        _uplineMatrixInfo.referrals.push(msg.sender);

        if(uplineUserId == 1){
            owner.transfer(msg.value);
        }else{
            uint profit = msg.value /2;

            //update direct upline matrix

            if (_uplineMatrixInfo.enterred == 3){
                _uplineMatrixInfo.enterred = 0;
                _uplineMatrixInfo.totalcyle += 1;

                // send profit  50% of entery value 
                uplineAddress.transfer(profit);
                balance[uplineAddress] += profit;


                address xRefAddress = uplineAddress;

                for(int i=1 ; i<=2 ; i++){
                    address indirectUpline = getUpline(xRefAddress);
                    if(indirectUpline != address(0)){
                        indirectUpline.transfer(profit/2);
                        balance[indirectUpline] += profit/2;
                        xRefAddress = indirectUpline;
                    }else{
                        owner.transfer(profit/2);
                    }
                }

            }
        }
        members.push(msg.sender)-1;
        totalTransactions += msg.value;
        matrixTransaction[packageLvl] += 1;
    }
    function buynewpackage() external payable{
        require(msg.value >= 0.5 ether , "upgrade starts from 0.05 eth");

        //check if address already exite
        uint memberId = getUserId(msg.sender);
        require(memberId > 0, "register to level 1 first");

        uint packageLvl = getPackageLevel(msg.value);
        require(packageLvl > 1, "invalid  package amount entry");

        // check if upline has a sam package 
        bool hasPackage = matrixInfos[memberId][packageLvl].isActive;
        require(!hasPackage, "you are already registered to this level !");

        // create new level matrix details
        MatrixInfo storage  _newMatrixInfo =  matrixInfos[memberId][packageLvl];
        _newMatrixInfo.isActive = true;

        //compute profit to send
        uint profit = msg.value/2;

        //1st level upline
        address directUpline = getUpline(msg.sender);
        if(directUpline != address(0)){
            directUpline.transfer(profit);
            balance[directUpline] += profit;
            owner.transfer(profit);
        }else{
            owner.transfer(msg.value);
        }

        totalTransactions += msg.value;
        matrixTransaction[packageLvl] += 1;
    }

    function getPackageLevel(uint amount) internal pure returns(uint){
        uint level = 0;

        if(amount == 0.5 ether){
            level = 2;
        }else if(amount  == 1 ether){
            level = 3;
        }else if(amount == 3 ether){
            level = 4;
        }else if(amount == 5 ether){
            level = 5;
        }else if(amount == 10 ether){
            level = 6;
        }else if(amount == 15 ether){
            level = 7;
        }else if(amount == 20 ether){
            level = 8;
        }else if(amount == 30 ether){
            level = 9;
        }else if(amount == 50 ether){
            level = 10;
        }else{
            level = 1;
        }
        return level;
    }

    // other public functions to use to retriever data

    function getUserId(address _address) public view returns(uint){
        
        if(_address == owner){
            return 1;  
        }
        return (memberInfos[_address].userID);
    }

    function getUpline(address _address) public view returns(address){
        return(memberInfos[_address].referrer);
    }

    function getMatrixInfo(uint userId, uint level)public view returns(bool, uint, uint){
        return(matrixInfos[userId][level].isActive, matrixInfos[userId][level].enterred, matrixInfos[userId][level].totalcyle);
    }

    function getAllReferrals(address _address, uint level) public view returns(address[]){
        uint memberId = getUserId(_address);
        return (matrixInfos[memberId][level].referrals);
    }

    function getAllReferralsById(uint userId, uint level) public view returns(address[]){
        return (matrixInfos[userId][level].referrals);
    }

    function totalMembers() public view returns(uint){
        return members.length;
    }

}