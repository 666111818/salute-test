// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SalukiToken is ERC20, Ownable {
    uint256 public constant TOTAL_SUPPLY = 1000 * 10**9 * 10**18; // 1000亿代币
    uint256 public constant PRIVATE_SALE_SUPPLY = 500 * 10**9 * 10**18; // 500亿代币用于私募
    uint256 public constant SALE_PRICE = 59 * 10**6; // 59 USDT (假设USDT有6位小数)
    uint256 public constant TOKENS_PER_PURCHASE = 25 * 10**6 * 10**18; // 每次私募2500万代币
    uint256 public constant MAX_PURCHASES = 2000; // 最多2000个地址购买

    address public usdtAddress; // USDT 合约地址，用于接收私募支付
    address public blackHole = address(0); // 黑洞地址用于销毁代币
    address public lpAddress; // 用于追踪流动性池的地址

    uint256 public purchases = 0; // 已购买的地址数
    bool public isLPAdded = false; // 是否已添加流动性池

    mapping(address => bool) public hasPurchased; // 记录每个地址是否已参与私募

    event TokensPurchased(address indexed buyer, uint256 amount); // 购买事件
    event LPAdded(address lpAddress); // 流动性池添加事件

    // 构造函数：初始化代币名称、符号、总供应量以及设置USDT地址
    constructor(address _usdtAddress) ERC20("$Saluki", "$SALUKI") Ownable(msg.sender) {
        _mint(address(this), TOTAL_SUPPLY); // 创建总供应量并存入合约地址
        usdtAddress = _usdtAddress; // 设置USDT合约地址
    }

    modifier onlyWhenLPAdded() {
        require(isLPAdded, "LP not added yet"); // 流动性池添加前禁止代币转账
        _;
    }

    function addLP(address _lpAddress) external onlyOwner {
        lpAddress = _lpAddress;
        isLPAdded = true;
        emit LPAdded(_lpAddress); // 记录流动性池地址并允许转账
    }

    function purchaseTokens() external {
        require(purchases < MAX_PURCHASES, "All tokens for sale are sold out"); // 检查是否达到最大购买限制
        require(!hasPurchased[msg.sender], "Address has already purchased"); // 检查地址是否已购买
        require(IERC20(usdtAddress).transferFrom(msg.sender, address(this), SALE_PRICE), "Insufficient USDT"); // 检查USDT转账成功

        hasPurchased[msg.sender] = true; // 记录购买状态
        purchases += 1;
        _transfer(address(this), msg.sender, TOKENS_PER_PURCHASE); // 转移代币到购买者
        emit TokensPurchased(msg.sender, TOKENS_PER_PURCHASE);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(isLPAdded || msg.sender == owner(), "LP not added yet"); // 检查流动性池是否添加
        uint256 burnAmount = (amount * 2) / 100; // 2% 销毁
        uint256 sendAmount = amount - burnAmount;

        _transfer(_msgSender(), recipient, sendAmount); // 转账到接收人
        _transfer(_msgSender(), blackHole, burnAmount); // 转账到黑洞地址，销毁2%
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(isLPAdded || sender == owner(), "LP not added yet"); // 检查流动性池是否添加
        uint256 burnAmount = (amount * 2) / 100; // 2% 销毁
        uint256 sendAmount = amount - burnAmount;

        _transfer(sender, recipient, sendAmount); // 转账到接收人
        _transfer(sender, blackHole, burnAmount); // 转账到黑洞地址，销毁2%
        _approve(sender, _msgSender(), allowance(sender, _msgSender()) - amount); // 更新授权额度
        return true;
    }

    function withdrawUSDT() external onlyOwner {
        uint256 usdtBalance = IERC20(usdtAddress).balanceOf(address(this));
        require(IERC20(usdtAddress).transfer(owner(), usdtBalance), "USDT withdrawal failed"); // 将USDT转移到所有者地址
    }
}