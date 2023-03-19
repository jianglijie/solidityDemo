pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract StakeReward is Ownable, ReentrancyGuard {
    struct UserInfo {
        uint256 amount;
        int256 rewardDebt;
    }

    struct PoolInfo {
        uint128 accRewardPerShare;
        uint64  lastRewardBlock;
        uint64  allocPoint;
    }

    IERC20 public immutable RTD;
    PoolInfo[] public poolInfo;
    IERC20[] public lpToken;

    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint;

    uint256 private constant TOKEN_PER_BLOCK = 100 * 1e18;
    uint256 private constant ACC_TOKEN_PRECISION = 1e12;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event LogPoolAddition(uint256 indexed pid, uint256 allocPoint, IERC20 indexed lpToken);
    event LogSetPool(uint256 indexed pid, uint256 allocPoint);
    event LogUpdatePool(uint256 indexed pid, uint64 lastRewardBlock, uint256 lpSupply, uint256 accRewardPerShare);

    constructor(IERC20 _reward) {
        RTD = _reward;
    }

    function add(uint256 allocPoint, IERC20 _lpToken) public onlyOwner {
        uint256 lastRewardBlock = block.number;
        totalAllocPoint = totalAllocPoint + allocPoint;
        lpToken.push(_lpToken);

        poolInfo.push(PoolInfo({
            allocPoint: uint64(allocPoint),
            lastRewardBlock: uint64(lastRewardBlock),
            accRewardPerShare: 0
        }));
        emit LogPoolAddition(lpToken.length - 1, allocPoint, _lpToken);
    }

    function set(uint256 _pid, uint256 _allocPoint) public onlyOwner {
        totalAllocPoint = totalAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;
        poolInfo[_pid].allocPoint = uint64(_allocPoint);
        emit LogSetPool(_pid, _allocPoint);
    }

    function pendingReward(uint256 _pid, address _user) external view returns (uint256 pending) {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 lpSupply = lpToken[_pid].balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 blocks = block.number - pool.lastRewardBlock;
            uint256 tokenReward = blocks * TOKEN_PER_BLOCK * pool.allocPoint / totalAllocPoint;
            accRewardPerShare = accRewardPerShare + tokenReward * ACC_TOKEN_PRECISION / lpSupply;
        }
        pending = user.amount * accRewardPerShare / ACC_TOKEN_PRECISION - uint256(user.rewardDebt);
    }

    function massUpdatePools(uint256[] calldata poolIDs) external {
        uint256 len = poolIDs.length;
        for (uint256 i = 0; i < len; ++i) {
            updatePool(poolIDs[i]);
        }
    }

    function updatePool(uint256 pid) public returns (PoolInfo memory pool) {
        pool = poolInfo[pid];
        if (block.number > pool.lastRewardBlock) {
            uint256 lpSupply = lpToken[pid].balanceOf(address(this));
            if (lpSupply > 0) {
                uint256 blocks = block.number - pool.lastRewardBlock;
                uint256 tokenReward = blocks * TOKEN_PER_BLOCK * pool.allocPoint / totalAllocPoint;
                pool.accRewardPerShare = pool.accRewardPerShare+ uint128(tokenReward * ACC_TOKEN_PRECISION / lpSupply);
            }
            pool.lastRewardBlock = uint64(block.number);
            poolInfo[pid] = pool;
            emit LogUpdatePool(pid, pool.lastRewardBlock, lpSupply, pool.accRewardPerShare);
        }
    }

    function deposit(uint256 pid, uint256 amount, address to) public {
        PoolInfo memory pool = updatePool(pid);
        UserInfo storage user = userInfo[pid][to];

        // Effects
        user.amount = user.amount + amount;
        user.rewardDebt = user.rewardDebt + int256(amount * pool.accRewardPerShare / ACC_TOKEN_PRECISION);

        lpToken[pid].transferFrom(msg.sender, address(this), amount);

        emit Deposit(msg.sender, pid, amount, to);
    }

    function withdraw(uint256 pid, uint256 amount, address to) public {
        PoolInfo memory pool = updatePool(pid);
        UserInfo storage user = userInfo[pid][msg.sender];

        // Effects
        user.rewardDebt = user.rewardDebt - int256(amount * pool.accRewardPerShare / ACC_TOKEN_PRECISION);
        user.amount = user.amount - amount;

        lpToken[pid].transfer(to, amount);

        emit Withdraw(msg.sender, pid, amount, to);
    }

    function harvest(uint256 pid, address to) public {
        PoolInfo memory pool = updatePool(pid);
        UserInfo storage user = userInfo[pid][msg.sender];
        int256 accumulatedToken = int256(user.amount * pool.accRewardPerShare / ACC_TOKEN_PRECISION);
        uint256 _pendingReward = uint256(accumulatedToken - user.rewardDebt);

        // Effects
        user.rewardDebt = accumulatedToken;

        // Interactions
        if (_pendingReward != 0) {
            RTD.transfer(to, _pendingReward);
        }

        emit Harvest(msg.sender, pid, _pendingReward);
    }

    function withdrawAndHarvest(uint256 pid, uint256 amount, address to) public {
        PoolInfo memory pool = updatePool(pid);
        UserInfo storage user = userInfo[pid][msg.sender];
        int256 accumulatedToken = int256(user.amount * pool.accRewardPerShare / ACC_TOKEN_PRECISION);
        uint256 _pendingReward = uint256(accumulatedToken - user.rewardDebt);

        // Effects
        user.rewardDebt = accumulatedToken - int256(amount * pool.accRewardPerShare / ACC_TOKEN_PRECISION);
        user.amount = user.amount - amount;

        // Interactions
        if (_pendingReward != 0) {
            RTD.transfer(to, _pendingReward);
        }

        lpToken[pid].transfer(to, amount);

        emit Withdraw(msg.sender, pid, amount, to);
        emit Harvest(msg.sender, pid, _pendingReward);
    }

    function emergencyWithdraw(uint256 pid, address to) public {
        UserInfo storage user = userInfo[pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;

        // Note: transfer can fail or succeed if `amount` is zero.
        lpToken[pid].transfer(to, amount);
        emit EmergencyWithdraw(msg.sender, pid, amount, to);
    }
}
