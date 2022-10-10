pragma solidity ^0.8.17;

contract Lottery{

    struct Item{
        uint itemId;
        string itemName;
        string photoHash;
        bool itemAvailable;
        uint[] biddersId;
        string description;
    }

    struct person{
        uint personId;
        string name;
        address personHash;
        Item[] itemWon;
        uint tokens;
        string role;
    }


    mapping(address=>person) bidders;
    mapping(uint=>address) bidder;
    address payable public owner;
    mapping(uint => Item) public items;
    uint itemCount = 0;
    uint personCount = 0;


    constructor() public {
            owner  = payable(msg.sender);
            bidders[owner].name = "admin";
            bidders[owner].personHash = msg.sender;
            bidders[owner].tokens = 0;
            bidders[owner].role = "admin";

   }
    

    modifier ownerOnly{
        require(msg.sender == owner);
        _;
    }


    modifier notOwner{
        require(msg.sender != owner);
        _;
    }

    function addItem(string memory _name,string memory _photoHash , string memory description)public ownerOnly{
        // items[itemCount] = Item({itemId:itemCount,itemName:_name,photoHash:_photoHash,itemAvailable:true,biddresId:emptyArray});
        items[itemCount].itemId = itemCount;
        items[itemCount].itemName = _name;
        items[itemCount].photoHash = _photoHash;
        items[itemCount].itemAvailable = true;
        items[itemCount].description = description;
        itemCount++;
    }

    function register(string memory _name) public payable notOwner{
        
        // bidders[msg.sender] = person({personId:personCount,name:_name,personhash:msg.sender,itemWon:emptyArray,tokens:0});
        bidders[msg.sender].personId = personCount;
        bidders[msg.sender].name = _name;
        bidders[msg.sender].personHash  = msg.sender;
        bidders[msg.sender].tokens = 0;
        bidders[msg.sender].role = "user";
        bidder[personCount] = msg.sender;

        personCount++;
    }

    function getTokens(uint _token)public payable notOwner{
        require(_token > 0);
        bidders[msg.sender].tokens += _token;
        owner.transfer(_token * 1000000000);
    }

    function bid(uint _itemId , uint _token)public payable notOwner{
        require(bidders[msg.sender].tokens >= _token);
        uint personId = bidders[msg.sender].personId;
        for(uint i = 0 ; i < _token;i++){
            items[_itemId].biddersId.push(personId);
        }
        uint tokens = bidders[msg.sender].tokens;
        tokens = tokens - _token;
        bidders[msg.sender].tokens = tokens;

    }

    function revealWinners(uint _itemId)public payable ownerOnly{
            if(items[_itemId].itemAvailable){
                Item storage currentItem = items[_itemId];
                if(currentItem.biddersId.length != 0){
                    uint randomIndex = (block.number / currentItem.biddersId.length)% currentItem.biddersId.length; 
                    uint winnerId = currentItem.biddersId[randomIndex];
                    address personAddress = bidder[winnerId];
                    bidders[personAddress].itemWon.push(currentItem);
                    items[_itemId].itemAvailable = false;
                }
            }
    }

    function getPersonsalDetails() public view returns(uint,string memory,Item[] memory ,uint ,string memory){
        return (bidders[msg.sender].personId,bidders[msg.sender].name,bidders[msg.sender].itemWon,bidders[msg.sender].tokens,bidders[msg.sender].role);
    }

    function getItemById(uint _id) public view returns(uint,string memory,string memory,bool){
        return (items[_id].itemId,items[_id].itemName,items[_id].photoHash,items[_id].itemAvailable);
    }

   function getAllItems() public view returns (Item[] memory){
    Item[] memory ret = new Item[](itemCount);
    for (uint i = 0; i < itemCount; i++) {
            
            ret[i] = items[i]; 
    }
    return ret;
}

}