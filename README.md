# 🏦 KipuBank

## 📖 Descripción
Contrato inteligente que permite depósitos y retiros limitados de ETH con capacidad máxima.

## ✨ Funcionalidades
- Depósitos de ETH en bóvedas personales
- Retiros con límite por transacción 
- Límite global de capacidad del banco
- Eventos y errores personalizados

## 🚀 Despliegue con Remix

### 1. Compilar
- Ve a [remix.ethereum.org](https://remix.ethereum.org/)
- Crea un nuevo archivo `KipuBank.sol` en la carpeta `contracts`
- Pega el código del contrato
- Ve a la pestaña **Solidity Compiler**
- Selecciona versión 0.8.19
- Haz clic en **Compile KipuBank.sol**

### 2. Desplegar
- Ve a la pestaña **Deploy & Run Transactions**
- Selecciona **Injected Provider - MetaMask** (conecta tu wallet)
- Elige la testnet **Sepolia**
- En los parámetros del constructor:
  - `_bankCap`: 100000000000000000000 (100 ETH en wei)
  - `_withdrawalLimit`: 5000000000000000000 (5 ETH en wei)
- Haz clic en **Transact** y confirma en MetaMask

### 3. Verificar (Opcional pero recomendado)
- Ve al explorador de bloques (Etherscan Sepolia)
- Busca la dirección de tu contrato
- Haz clic en **Verify and Publish**
- Sigue las instrucciones para verificar el código

## 📝 Cómo Interactuar

### Depósito
```javascript
// En Remix, selecciona la función deposit()
// En Value: ingresa la cantidad en ETH (ej: 1 ETH)
// Haz clic en deposit
