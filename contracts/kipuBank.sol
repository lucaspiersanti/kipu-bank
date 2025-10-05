// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * @title KipuBank
 * @dev Un contrato bancario simple que permite depósitos y retiros limitados de ETH
 * @author Lucas Piersanti
 * @notice Los usuarios pueden depositar ETH y retirar hasta un límite por transacción con capacidad máxima del banco
 */
contract KipuBank {
    // =============================================
    // ERRORES PERSONALIZADOS
    // =============================================
    
    /// @dev Error cuando el depósito excede el límite del banco
    error ExceedsBankCap();
    
    /// @dev Error cuando el retiro excede el límite por transacción
    error ExceedsWithdrawalLimit();
    
    /// @dev Error cuando el usuario no tiene fondos suficientes
    error InsufficientFunds();
    
    /// @dev Error cuando la transferencia falla
    error TransferFailed();
    
    /// @dev Error cuando el monto es cero
    error ZeroAmount();
    
    /// @dev Error cuando el caller no es el owner
    error Unauthorized();

    // =============================================
    // EVENTOS
    // =============================================
    
    /**
     * @dev Emitido cuando un usuario deposita ETH
     * @param user Dirección del usuario que depositó
     * @param amount Cantidad de ETH depositada
     * @param newBalance Nuevo balance del usuario
     */
    event Deposited(address indexed user, uint256 amount, uint256 newBalance);
    
    /**
     * @dev Emitido cuando un usuario retira ETH
     * @param user Dirección del usuario que retiró
     * @param amount Cantidad de ETH retirada
     * @param newBalance Nuevo balance del usuario
     */
    event Withdrawn(address indexed user, uint256 amount, uint256 newBalance);
    
    /**
     * @dev Emitido cuando el contrato es desplegado
     * @param owner Dirección del owner del contrato
     * @param bankCap Capacidad máxima del banco
     * @param withdrawalLimit Límite de retiro por transacción
     */
    event BankDeployed(address indexed owner, uint256 bankCap, uint256 withdrawalLimit);

    // =============================================
    // VARIABLES DE ESTADO INMUTABLES
    // =============================================
    
    /// @dev Límite máximo de ETH que puede tener el banco
    uint256 public immutable bankCap;
    
    /// @dev Dirección del owner del contrato
    address public immutable owner;

    // =============================================
    // VARIABLES DE ESTADO PÚBLICAS
    // =============================================
    
    /// @dev Límite máximo por transacción de retiro
    uint256 public withdrawalLimit;

    // =============================================
    // VARIABLES DE ESTADO PRIVADAS
    // =============================================
    
    /// @dev Balance de ETH de cada usuario
    mapping(address => uint256) private _userBalances;
    
    /// @dev Total de ETH depositado en el banco
    uint256 private _totalDeposits;
    
    /// @dev Contador de depósitos realizados
    uint256 private _totalDepositCount;
    
    /// @dev Contador de retiros realizados
    uint256 private _totalWithdrawalCount;

    // =============================================
    // MODIFICADORES
    // =============================================
    
    /**
     * @notice Verifica que el monto no sea cero
     * @param _amount Monto a verificar
     */
    modifier nonZeroAmount(uint256 _amount) {
        if (_amount == 0) revert ZeroAmount();
        _;
    }
    
    /**
     * @notice Verifica que no se exceda el límite del banco
     * @param _amount Monto a verificar
     */
    modifier withinBankCap(uint256 _amount) {
        if (_totalDeposits + _amount > bankCap) revert ExceedsBankCap();
        _;
    }
    
    /**
     * @notice Verifica que solo el owner pueda ejecutar la función
     */
    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    // =============================================
    // CONSTRUCTOR
    // =============================================
    
    /**
     * @notice Inicializa el contrato con límites específicos
     * @param _bankCap Límite máximo total de depósitos en el banco
     * @param _withdrawalLimit Límite máximo por retiro
     */
    constructor(uint256 _bankCap, uint256 _withdrawalLimit) payable {
        bankCap = _bankCap;
        withdrawalLimit = _withdrawalLimit;
        owner = msg.sender;
        
        emit BankDeployed(msg.sender, _bankCap, _withdrawalLimit);
    }

    // =============================================
    // FUNCIONES EXTERNAS
    // =============================================

    /**
     * @notice Permite a los usuarios depositar ETH en su bóveda personal
     * @dev El depósito no puede exceder el límite total del banco
     * @dev Emite un evento Deposited en caso de éxito
     */
    function deposit() external payable nonZeroAmount(msg.value) withinBankCap(msg.value) {
        // Cache de variables de estado para optimizar gas
        uint256 currentUserBalance = _userBalances[msg.sender];
        uint256 newUserBalance = currentUserBalance + msg.value;
        uint256 newTotalDeposits = _totalDeposits + msg.value;
        uint256 newDepositCount = _totalDepositCount + 1;
        
        // EFFECTS: Actualizar estado interno
        _userBalances[msg.sender] = newUserBalance;
        _totalDeposits = newTotalDeposits;
        _totalDepositCount = newDepositCount;
        
        // INTERACTIONS: No hay interacciones externas en esta función
        
        // Emitir evento
        emit Deposited(msg.sender, msg.value, newUserBalance);
    }

    /**
     * @notice Permite a los usuarios retirar ETH de su bóveda
     * @dev El retiro no puede exceder el límite por transacción ni el balance del usuario
     * @param _amount Cantidad de ETH a retirar
     */
    function withdraw(uint256 _amount) external nonZeroAmount(_amount) {
        // Cache de variables de estado para optimizar gas
        uint256 currentUserBalance = _userBalances[msg.sender];
        uint256 currentWithdrawalLimit = withdrawalLimit;
        uint256 currentTotalDeposits = _totalDeposits;
        uint256 newWithdrawalCount = _totalWithdrawalCount + 1;
        
        // CHECKS: Verificaciones de seguridad (usando <= en lugar de < para ahorrar gas)
        if (_amount > currentWithdrawalLimit) {
            revert ExceedsWithdrawalLimit();
        }
        
        if (_amount > currentUserBalance) {
            revert InsufficientFunds();
        }
        
        // EFFECTS: Actualizar estado interno (antes de la interacción)
        uint256 newUserBalance = currentUserBalance - _amount;
        uint256 newTotalDeposits = currentTotalDeposits - _amount;
        
        _userBalances[msg.sender] = newUserBalance;
        _totalDeposits = newTotalDeposits;
        _totalWithdrawalCount = newWithdrawalCount;
        
        // INTERACTIONS: Transferir ETH al usuario
        (bool success, ) = msg.sender.call{value: _amount}("");
        if (!success) revert TransferFailed();
        
        // Emitir evento
        emit Withdrawn(msg.sender, _amount, newUserBalance);
    }

    // =============================================
    // FUNCIONES DE VISTA (VIEW)
    // =============================================

    /**
     * @notice Obtiene el balance de un usuario
     * @param _user Dirección del usuario
     * @return Balance del usuario en ETH
     */
    function getBalance(address _user) external view returns (uint256) {
        return _userBalances[_user];
    }
    
    /**
     * @notice Verifica si el banco ha alcanzado su capacidad máxima
     * @return true si el banco está lleno, false en caso contrario
     */
    function isBankFull() external view returns (bool) {
        return _totalDeposits >= bankCap;
    }
    
    /**
     * @notice Obtiene estadísticas del banco
     * @return totalDeposited Total de ETH depositado
     * @return depositCount Número total de depósitos
     * @return withdrawalCount Número total de retiros
     * @return currentCap Capacidad actual utilizada
     * @return maxCap Capacidad máxima del banco
     */
    function getBankStats() external view returns (
        uint256 totalDeposited,
        uint256 depositCount,
        uint256 withdrawalCount,
        uint256 currentCap,
        uint256 maxCap
    ) {
        return (
            _totalDeposits,
            _totalDepositCount,
            _totalWithdrawalCount,
            _totalDeposits,
            bankCap
        );
    }
    
    /**
     * @notice Obtiene el límite de retiro actual
     * @return Límite actual de retiro por transacción
     */
    function getWithdrawalLimit() external view returns (uint256) {
        return withdrawalLimit;
    }

    // =============================================
    // FUNCIONES DEL OWNER
    // =============================================

    /**
     * @notice Permite al owner cambiar el límite de retiro
     * @dev Solo el owner puede llamar esta función
     * @param _newLimit Nuevo límite de retiro por transacción
     */
    function setWithdrawalLimit(uint256 _newLimit) external onlyOwner {
        withdrawalLimit = _newLimit;
    }

    // =============================================
    // FUNCIONES PRIVADAS
    // =============================================

    /**
     * @dev Función interna para verificar si un monto es válido
     * @param _amount Monto a verificar
     * @return true si el monto es mayor que cero
     */
    function _isValidAmount(uint256 _amount) private pure returns (bool) {
        return _amount > 0;
    }
}