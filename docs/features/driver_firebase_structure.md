# Estrutura de Dados do Firebase para Motoristas

Este documento define a estrutura de dados no Firestore para o módulo de motoristas, seguindo as regras de negócio definidas em `/regrasdenegocio.md`.

## Coleções Principais

### 1. drivers/{driverId}
```json
{
  "id": "string",
  "personalInfo": {
    "fullName": "string",
    "cpf": "string",
    "rg": "string",
    "birthDate": "timestamp",
    "phone": "string",
    "email": "string",
    "address": {
      "street": "string",
      "number": "string",
      "complement": "string",
      "neighborhood": "string",
      "city": "string",
      "state": "string",
      "zipCode": "string"
    }
  },
  "vehicleInfo": {
    "licensePlate": "string",
    "brand": "string",
    "model": "string",
    "year": "number",
    "color": "string",
    "category": "economy|comfort|premium",
    "capacity": "number",
    "features": ["air_conditioning", "wifi", "phone_charger"]
  },
  "documents": {
    "driverLicense": {
      "number": "string",
      "category": "string",
      "expiryDate": "timestamp",
      "photoUrl": "string",
      "verified": "boolean"
    },
    "vehicleRegistration": {
      "number": "string",
      "expiryDate": "timestamp",
      "photoUrl": "string",
      "verified": "boolean"
    },
    "criminalRecord": {
      "photoUrl": "string",
      "verified": "boolean"
    },
    "profilePhoto": {
      "photoUrl": "string",
      "verified": "boolean"
    }
  },
  "workConfig": {
    "pricingConfig": {
      "baseRate": "number",
      "perKmRate": "number",
      "perMinuteRate": "number",
      "minimumFare": "number",
      "surgePricing": "boolean",
      "maxSurgeMultiplier": "number"
    },
    "serviceFees": {
      "petTransport": {
        "enabled": "boolean",
        "fee": "number"
      },
      "trunk": {
        "enabled": "boolean",
        "fee": "number"
      },
      "condominiumAccess": {
        "enabled": "boolean",
        "fee": "number"
      },
      "stops": {
        "enabled": "boolean",
        "feePerStop": "number",
        "maxStops": "number"
      }
    },
    "workingArea": {
      "coordinates": [
        {
          "latitude": "number",
          "longitude": "number"
        }
      ],
      "excludedNeighborhoods": ["string"]
    }
  },
  "currentStatus": "offline|online|onTrip|paused|suspended|busy",
  "currentLocation": {
    "latitude": "number",
    "longitude": "number",
    "accuracy": "number",
    "timestamp": "timestamp"
  },
  "verificationStatus": "pending|approved|rejected",
  "isActive": "boolean",
  "rating": {
    "average": "number",
    "totalRides": "number",
    "totalRatings": "number"
  },
  "appSettings": {
    "language": "string",
    "theme": "light|dark|system",
    "soundEnabled": "boolean",
    "vibrationEnabled": "boolean",
    "autoAcceptRides": "boolean",
    "maxDistanceForRides": "number"
  },
  "notificationSettings": {
    "rideRequests": "boolean",
    "promotions": "boolean",
    "systemUpdates": "boolean",
    "earnings": "boolean"
  },
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### 2. drivers/{driverId}/status_history/{historyId}
```json
{
  "id": "string",
  "driverId": "string",
  "previousStatus": "offline|online|onTrip|paused|suspended|busy",
  "newStatus": "offline|online|onTrip|paused|suspended|busy",
  "timestamp": "timestamp",
  "reason": "string",
  "location": {
    "latitude": "number",
    "longitude": "number",
    "accuracy": "number",
    "timestamp": "timestamp"
  }
}
```

### 3. drivers/{driverId}/earnings/{earningId}
```json
{
  "id": "string",
  "driverId": "string",
  "rideId": "string",
  "amount": "number",
  "currency": "BRL",
  "breakdown": {
    "baseFare": "number",
    "distanceFare": "number",
    "timeFare": "number",
    "serviceFees": "number",
    "surge": "number",
    "tips": "number"
  },
  "date": "timestamp",
  "status": "pending|paid|cancelled"
}
```

### 4. drivers/{driverId}/ratings/{ratingId}
```json
{
  "id": "string",
  "driverId": "string",
  "rideId": "string",
  "passengerId": "string",
  "rating": "number",
  "comment": "string",
  "timestamp": "timestamp"
}
```

### 5. drivers/{driverId}/notifications/{notificationId}
```json
{
  "id": "string",
  "driverId": "string",
  "type": "ride_request|promotion|system_update|earning",
  "title": "string",
  "message": "string",
  "data": "object",
  "read": "boolean",
  "timestamp": "timestamp"
}
```

### 6. ride_requests/{requestId}
```json
{
  "id": "string",
  "passengerId": "string",
  "pickupLocation": {
    "latitude": "number",
    "longitude": "number",
    "address": "string"
  },
  "dropoffLocation": {
    "latitude": "number",
    "longitude": "number",
    "address": "string"
  },
  "vehicleCategory": "economy|comfort|premium",
  "estimatedFare": "number",
  "estimatedDistance": "number",
  "estimatedDuration": "number",
  "specialRequests": ["pet_transport", "trunk", "condominium_access"],
  "stops": [
    {
      "latitude": "number",
      "longitude": "number",
      "address": "string"
    }
  ],
  "status": "pending|accepted|cancelled|expired",
  "assignedDriverId": "string",
  "createdAt": "timestamp",
  "expiresAt": "timestamp"
}
```

### 7. rides/{rideId}
```json
{
  "id": "string",
  "requestId": "string",
  "driverId": "string",
  "passengerId": "string",
  "pickupLocation": {
    "latitude": "number",
    "longitude": "number",
    "address": "string"
  },
  "dropoffLocation": {
    "latitude": "number",
    "longitude": "number",
    "address": "string"
  },
  "stops": [
    {
      "latitude": "number",
      "longitude": "number",
      "address": "string",
      "completed": "boolean",
      "completedAt": "timestamp"
    }
  ],
  "status": "accepted|driver_arriving|arrived|in_progress|completed|cancelled",
  "fare": {
    "total": "number",
    "breakdown": {
      "baseFare": "number",
      "distanceFare": "number",
      "timeFare": "number",
      "serviceFees": "number",
      "surge": "number"
    }
  },
  "actualDistance": "number",
  "actualDuration": "number",
  "route": [
    {
      "latitude": "number",
      "longitude": "number",
      "timestamp": "timestamp"
    }
  ],
  "timeline": {
    "acceptedAt": "timestamp",
    "arrivedAt": "timestamp",
    "startedAt": "timestamp",
    "completedAt": "timestamp"
  },
  "payment": {
    "method": "credit_card|debit_card|pix|cash",
    "status": "pending|completed|failed",
    "transactionId": "string"
  },
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## Índices Recomendados

### Para drivers
- `currentStatus` (para buscar motoristas online)
- `currentLocation` (para busca geográfica)
- `verificationStatus` (para filtrar motoristas aprovados)
- `isActive` (para filtrar motoristas ativos)

### Para ride_requests
- `status` (para buscar solicitações pendentes)
- `vehicleCategory` (para filtrar por categoria)
- `createdAt` (para ordenação temporal)
- `pickupLocation` (para busca geográfica)

### Para rides
- `driverId` + `status` (para buscar viagens ativas do motorista)
- `passengerId` + `status` (para buscar viagens do passageiro)
- `status` (para relatórios gerais)
- `createdAt` (para ordenação temporal)

## Regras de Segurança (Security Rules)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Motoristas só podem acessar seus próprios dados
    match /drivers/{driverId} {
      allow read, write: if request.auth != null && request.auth.uid == driverId;
      
      // Subcoleções do motorista
      match /{subcollection}/{document} {
        allow read, write: if request.auth != null && request.auth.uid == driverId;
      }
    }
    
    // Solicitações de viagem podem ser lidas por motoristas verificados
    match /ride_requests/{requestId} {
      allow read: if request.auth != null && 
        exists(/databases/$(database)/documents/drivers/$(request.auth.uid)) &&
        get(/databases/$(database)/documents/drivers/$(request.auth.uid)).data.verificationStatus == 'approved';
      allow write: if request.auth != null && request.auth.uid == resource.data.assignedDriverId;
    }
    
    // Viagens podem ser acessadas pelo motorista ou passageiro
    match /rides/{rideId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.driverId || request.auth.uid == resource.data.passengerId);
    }
  }
}
```

## Observações Importantes

1. **excluded_neighborhoods**: Salvos no workConfig.workingArea conforme regra de negócio
2. **Timestamps**: Usar `FieldValue.serverTimestamp()` para consistência
3. **Geolocalização**: Usar GeoPoint do Firestore para consultas geográficas eficientes
4. **Status em tempo real**: Usar listeners para atualizações em tempo real
5. **Verificação**: Sistema de aprovação manual para novos motoristas
6. **Algoritmo de matching**: Baseado em proximidade, categoria do veículo e áreas de atendimento