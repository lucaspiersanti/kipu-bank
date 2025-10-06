# 🏦 KipuBank

## 📖 Descripción
Contrato inteligente que permite depósitos y retiros limitados de ETH con capacidad máxima.

## ✨ Funcionalidades
- Depósitos de ETH en bóvedas personales
- Retiros con límite por transacción 
- Límite global de capacidad del banco
- Eventos y errores personalizados

## 🌐 Contrato Desplegado

**Red:** Sepolia Testnet  
**Dirección:** `0x15E7085c1c1d125d48AFbDfe3521f732B8C28474`  
**Etherscan:** [Ver contrato en Sepolia Etherscan](https://sepolia.etherscan.io/address/0x15E7085c1c1d125d48AFbDfe3521f732B8C28474)  
**Estado:** ✅ Verificado

## 🚀 Despliegue con Remix

### 1. Compilar
- Ve a [remix.ethereum.org](https://remix.ethereum.org/)
- Crea un nuevo archivo `KipuBank.sol` en la carpeta `contracts`
- Pega el código del contrato
- Ve a la pestaña **Solidity Compiler**
- Selecciona versión 0.8.25
- Haz clic en **Compile KipuBank.sol**

### 2. Desplegar
- Ve a la pestaña **Deploy & Run Transactions**
- Selecciona **Injected Provider - MetaMask** (conecta tu wallet)
- Elige la testnet **Sepolia**
- En los parámetros del constructor:
  - `_bankCap`: 100000000000000000000 (100 ETH en wei)
  - `_withdrawalLimit`: 5000000000000000000 (5 ETH en wei)
- Haz clic en **Transact** y confirma en MetaMask

## 🚀 Cómo Interactuar con el Contrato

### **Paso 1: Acceder al Contrato**
1. Ve a: [https://sepolia.etherscan.io/address/0x15E7085c1c1d125d48AFbDfe3521f732B8C28474](https://sepolia.etherscan.io/address/0x15E7085c1c1d125d48AFbDfe3521f732B8C28474)
2. Haz clic en la pestaña **"Contract"**
3. Selecciona **"Write Contract"** o **"Read Contract"** según lo que necesites

### **Paso 2: Conectar Wallet**
1. En "Write Contract", haz clic en **"Connect to Web3"**
2. Conecta tu MetaMask (asegúrate de estar en red Sepolia)
3. Confirma la conexión
// Ejemplo para 0.1 ETH: 100000000000000000

## 🧩 Funciones Disponibles

### 🪙 `deposit()`
Permite a los usuarios depositar ETH en su cuenta personal dentro del banco.

```solidity
function deposit() external payable
```

**Requisitos:**
- El monto (`msg.value`) debe ser mayor que 0.
- El depósito no puede exceder la capacidad total del banco (`bankCap`).

**Evento emitido:**
```solidity
event Deposited(address indexed user, uint256 amount, uint256 newBalance);
```

---

### 💸 `withdraw(uint256 _amount)`
Permite retirar ETH del balance personal hasta el límite permitido.

```solidity
function withdraw(uint256 _amount) external
```

**Parámetros:**
| Parámetro | Tipo | Descripción |
|------------|------|-------------|
| `_amount` | `uint256` | Monto a retirar en wei o ETH. |

**Requisitos:**
- `_amount > 0`
- `_amount <= withdrawalLimit`
- `_amount <= balance del usuario`

**Evento emitido:**
```solidity
event Withdrawn(address indexed user, uint256 amount, uint256 newBalance);
```

---

### 👁️ `getBalance(address _user)`
Obtiene el balance de un usuario específico dentro del banco.

```solidity
function getBalance(address _user) external view returns (uint256)
```

**Parámetros:**
| Parámetro | Tipo | Descripción |
|------------|------|-------------|
| `_user` | `address` | Dirección del usuario. |

**Retorna:**
`uint256` → Monto en wei.

---

### 🏦 `isBankFull()`
Verifica si el banco alcanzó su capacidad máxima (`bankCap`).

```solidity
function isBankFull() external view returns (bool)
```

**Retorna:**
- `true` → si el banco está lleno.
- `false` → si aún hay capacidad disponible.

---

### 📊 `getBankStats()`
Devuelve estadísticas completas del estado actual del banco.

```solidity
function getBankStats() external view returns (
    uint256 totalDeposited,
    uint256 depositCount,
    uint256 withdrawalCount,
    uint256 currentCap,
    uint256 maxCap
)
```

**Retorna:**
| Valor | Descripción |
|--------|--------------|
| `totalDeposited` | Total de ETH actualmente depositado. |
| `depositCount` | Número total de depósitos realizados. |
| `withdrawalCount` | Número total de retiros realizados. |
| `currentCap` | Capacidad utilizada actual. |
| `maxCap` | Capacidad máxima del banco (`bankCap`). |

---

### 💰 `getWithdrawalLimit()`
Obtiene el límite actual de retiro por transacción.

```solidity
function getWithdrawalLimit() external view returns (uint256)
```

**Retorna:**
`uint256` → Límite actual en wei.

---

### 🔐 `setWithdrawalLimit(uint256 _newLimit)`
Permite al owner modificar el límite máximo de retiro.

```solidity
function setWithdrawalLimit(uint256 _newLimit) external onlyOwner
```

**Parámetros:**
| Parámetro | Tipo | Descripción |
|------------|------|-------------|
| `_newLimit` | `uint256` | Nuevo valor para el límite de retiro. |

**Restricciones:**
- Solo el `owner` (quien desplegó el contrato) puede llamarla.
- Si otro usuario intenta ejecutarla, lanzará el error `Unauthorized()`.

---

## ⚠️ Errores Personalizados

| Error | Descripción |
|--------|--------------|
| `ExceedsBankCap()` | El depósito excede la capacidad máxima del banco. |
| `ExceedsWithdrawalLimit()` | El retiro excede el límite permitido por transacción. |
| `InsufficientFunds()` | El usuario intenta retirar más de lo que posee. |
| `TransferFailed()` | Falló la transferencia de ETH. |
| `ZeroAmount()` | Se intentó usar un monto igual a cero. |
| `Unauthorized()` | Solo el owner puede ejecutar ciertas funciones. |
