pragma solidity ^0.8.0;
import "./ownable.sol";
import "./safemath.sol";
contract IOU is Ownable{
    using SafeMath for uint;

    uint[][] internal IOUs;   
    mapping(address => uint256) internal userIDs; 
    address[] users;
    uint internal total_users = 0;

    // Lay tong so no cua nguoi goi nao do
    // Chi cho phep nguoi goi do truy cap
    function getTotalOwed(address user) public view returns (uint256) {
        require(msg.sender == user, "ERROR!");
        uint amount = 0;
        uint user_ID = userIDs[user];
        for (uint i = 0; i < total_users;i++)
        {
            amount.add(IOUs[user_ID][i]);
        }
        return amount;
    }

    // Kiem tra xem user do ton tai trong he thong khong
    function findUser(address user) internal view returns (bool){
        for (uint i = 0; i < total_users;i++)
        {
            if (users[i] == user) return true;
        }
        return false;
    }

    //Them mot user vao he thong 
    function add_User(address user) internal{
        users.push(user);
        userIDs[user] = total_users;
        total_users= total_users + 1;
    }
    
    function dfs(uint[] memory visited, uint[] memory parent, uint current) internal returns (bool){
        visited[current] = 1;
        for (uint i = 0; i < total_users;i++)
        {
            if (IOUs[current][i] != 0)
            {
                if (visited[i] == 0) 
                {
                    parent[i] = current;
                    if(dfs(visited, parent, i)) return true;
                } 
                else if (visited[i] == 1) 
                {
                    uint temp_current = current;
                    uint min_amount = IOUs[temp_current][i];
                    while (temp_current != i) { 
                        if (IOUs[parent[temp_current]][temp_current] < min_amount) min_amount = IOUs[parent[temp_current]][temp_current];
                        temp_current = parent[temp_current];
                    }
                    temp_current = current;
                    IOUs[temp_current][i] = IOUs[temp_current][i] - min_amount;
                    while (temp_current != i) {
                        IOUs[parent[temp_current]][temp_current] = IOUs[parent[temp_current]][temp_current] - min_amount;
                        temp_current = parent[temp_current];
                    }
                    return true;
                }
            }
        }
        visited[current] = 2;
        return true;
    }

    //Sua lai so tien no
    function reset() internal{
        uint[] memory visited = new uint[](total_users);
        uint[] memory parent  = new uint[](total_users);
        for (uint i = 0; i < total_users;i++)
        {
            if (visited[i] == 0)
            {
                dfs(visited, parent, userIDs[msg.sender]);
            } 
        }
    }
    // Them mot so no vao so cai
    function add_IOU(address creditor, uint256 amount) public {
        require(amount >= 0, "ERROR!");
        if (total_users == 0) 
        {
            add_User(msg.sender);
            add_User(creditor);
            IOUs.push([0,0]);
            IOUs.push([0,0]);
        }
        else 
        {
            if (findUser(msg.sender) == false) 
            {
                for (uint i = 0; i < total_users;i++)
                {
                    IOUs[i].push(0);
                }
                IOUs.push([0]);
                for (uint i = 0; i < total_users;i++)
                {
                    IOUs[total_users].push(0);
                }
                add_User(msg.sender);
            }
            if (findUser(creditor) == false) 
            {
                for (uint i = 0; i < total_users;i++)
                {
                    IOUs[i].push(0);
                }
                IOUs.push([0]);
                for (uint i = 0; i < total_users;i++)
                {
                    IOUs[total_users].push(0);
                }
                add_User(creditor);
            }
        }
        address debtor = msg.sender;
        IOUs[userIDs[debtor]][userIDs[creditor]] = IOUs[userIDs[debtor]][userIDs[creditor]]  + amount;
        if (IOUs[userIDs[creditor]][userIDs[debtor]] != 0)
        {
            uint min_amount = IOUs[userIDs[creditor]][userIDs[debtor]];
            if (IOUs[userIDs[debtor]][userIDs[creditor]] < min_amount) min_amount = IOUs[userIDs[debtor]][userIDs[creditor]];
            IOUs[userIDs[creditor]][userIDs[debtor]] = IOUs[userIDs[creditor]][userIDs[debtor]] - min_amount;
            IOUs[userIDs[debtor]][userIDs[creditor]] = IOUs[userIDs[debtor]][userIDs[creditor]] - min_amount;
        }
        else reset(); 
    }

    // Tim so tien ma debtor no creditor nao do
    function lookup(address debtor, address creditor) public view returns(uint)
    {
        require(msg.sender == debtor || msg.sender == creditor, "ERROR!");
        return IOUs[userIDs[debtor]][userIDs[creditor]];
    }
}