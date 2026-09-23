package com.example.likhwao.Repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.likhwao.Entity.DeviceAccountLockEntity;

import java.util.Optional;

public interface DeviceAccountLockRepository extends JpaRepository<DeviceAccountLockEntity, Long> {

    Optional<DeviceAccountLockEntity> findByDeviceIdAndAppType(String deviceId, String appType);

    Optional<DeviceAccountLockEntity> findByAndroidIdAndAppType(String androidId, String appType);
}