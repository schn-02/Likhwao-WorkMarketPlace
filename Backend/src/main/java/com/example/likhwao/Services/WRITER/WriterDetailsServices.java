package com.example.likhwao.Services.WRITER;

import com.example.likhwao.Entity.DeviceAccountLockEntity;
import com.example.likhwao.Entity.WRITER.WriterDetailsEntity;
import com.example.likhwao.Model.AuthModel;
import com.example.likhwao.Repository.DeviceAccountLockRepository;
import com.example.likhwao.Repository.WRITER.WritersDetailsEntityRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.Optional;

@Service
public class WriterDetailsServices {

    private final WritersDetailsEntityRepository writerRepository;
    private final DeviceAccountLockRepository deviceLockRepository;

    @Autowired
    public WriterDetailsServices(
            WritersDetailsEntityRepository writerRepository,
            DeviceAccountLockRepository deviceLockRepository
    ) {
        this.writerRepository = writerRepository;
        this.deviceLockRepository = deviceLockRepository;
    }

    @Transactional
    public void saveWriters(AuthModel dto) {

        String appType = "WRITER_APP";

        Optional<DeviceAccountLockEntity> existingDeviceLock =
                deviceLockRepository.findByDeviceIdAndAppType(dto.getDeviceId(), appType);

        if (existingDeviceLock.isPresent()) {
            DeviceAccountLockEntity lock = existingDeviceLock.get();

            if (!lock.getFirebaseUid().equals(dto.getFirebaseUid())) {
                throw new RuntimeException("This device is already linked with another writer account");
            }
        }

        if (dto.getAndroidId() != null && !dto.getAndroidId().isBlank()) {
            Optional<DeviceAccountLockEntity> existingAndroidLock =
                    deviceLockRepository.findByAndroidIdAndAppType(dto.getAndroidId(), appType);

            if (existingAndroidLock.isPresent()) {
                DeviceAccountLockEntity lock = existingAndroidLock.get();

                if (!lock.getFirebaseUid().equals(dto.getFirebaseUid())) {
                    throw new RuntimeException("This device is already linked with another writer account");
                }
            }
        }

        Optional<WriterDetailsEntity> existingWriterByUid =
                writerRepository.findByFirebaseUid(dto.getFirebaseUid());

        if (existingWriterByUid.isPresent()) {
            WriterDetailsEntity existingWriter = existingWriterByUid.get();

            existingWriter.setEmail(dto.getEmail());
            existingWriter.setName(dto.getName());
            existingWriter.setCountryCode(dto.getCountryCode());
            existingWriter.setCountryName(dto.getCountryName());
            existingWriter.setPhoneNumber(dto.getPhoneNumber());
            existingWriter.setEmailVerified(dto.isEmailVerified());
            existingWriter.setDetailsCompleted(dto.isDetailsCompleted());
            existingWriter.setRole("WRITER");

            writerRepository.save(existingWriter);

            if (existingDeviceLock.isEmpty()) {
                createDeviceLock(dto, appType);
            }

            return;
        }

        Optional<WriterDetailsEntity> existingWriterByEmail =
                writerRepository.findByEmail(dto.getEmail());

        if (existingWriterByEmail.isPresent()) {
            throw new RuntimeException("This email is already registered with another writer account");
        }

        Optional<WriterDetailsEntity> existingWriterByPhone =
                writerRepository.findByPhoneNumber(dto.getPhoneNumber());

        if (existingWriterByPhone.isPresent()) {
            throw new RuntimeException("This phone number is already registered with another writer account");
        }

        WriterDetailsEntity entity = new WriterDetailsEntity();

        entity.setFirebaseUid(dto.getFirebaseUid());
        entity.setEmail(dto.getEmail());
        entity.setName(dto.getName());
        entity.setCountryCode(dto.getCountryCode());
        entity.setCountryName(dto.getCountryName());
        entity.setPhoneNumber(dto.getPhoneNumber());
        entity.setEmailVerified(dto.isEmailVerified());
        entity.setDetailsCompleted(dto.isDetailsCompleted());
        entity.setBlocked(false);
        entity.setTotalOrders(0);
        entity.setRole("WRITER");

        writerRepository.save(entity);

        if (existingDeviceLock.isEmpty()) {
            createDeviceLock(dto, appType);
        }

        System.out.println("Writer saved successfully");
    }

    private void createDeviceLock(AuthModel dto, String appType) {

        DeviceAccountLockEntity lock = new DeviceAccountLockEntity();

        lock.setDeviceId(dto.getDeviceId());
        lock.setAppType(appType);
        lock.setFirebaseUid(dto.getFirebaseUid());
        lock.setEmail(dto.getEmail());

        lock.setDeviceModel(dto.getDeviceModel());
        lock.setAndroidId(dto.getAndroidId());
        lock.setFirebaseInstallationId(dto.getFirebaseInstallationId());
        lock.setBrand(dto.getBrand());
        lock.setManufacturer(dto.getManufacturer());

        lock.setRooted(dto.isRooted());
        lock.setEmulator(dto.isEmulator());

        deviceLockRepository.save(lock);
    }

    public Map<String, Object> checkWriters(String deviceId, String firebaseUid) {

        String appType = "WRITER_APP";

        Optional<WriterDetailsEntity> writerOpt =
                writerRepository.findByFirebaseUid(firebaseUid);

        Optional<DeviceAccountLockEntity> lockOpt =
                deviceLockRepository.findByDeviceIdAndAppType(deviceId, appType);

        boolean writerExists = writerOpt.isPresent();

        boolean deviceMatched = lockOpt
                .map(lock -> lock.getFirebaseUid().equals(firebaseUid))
                .orElse(false);

        boolean deviceLockedByOtherAccount = lockOpt
                .map(lock -> !lock.getFirebaseUid().equals(firebaseUid))
                .orElse(false);

        boolean emailVerified = writerOpt
                .map(WriterDetailsEntity::isEmailVerified)
                .orElse(false);

        boolean detailsCompleted = writerOpt
                .map(WriterDetailsEntity::isDetailsCompleted)
                .orElse(false);

        boolean blocked = writerOpt
                .map(WriterDetailsEntity::getBlocked)
                .orElse(false);

        return Map.of(
                "writerExists", writerExists,
                "deviceMatched", deviceMatched,
                "deviceLockedByOtherAccount", deviceLockedByOtherAccount,
                "emailVerified", emailVerified,
                "detailsCompleted", detailsCompleted,
                "blocked", blocked
        );
    }

    public boolean canCreateAccount(String deviceId, String email) {

        String appType = "WRITER_APP";

        Optional<DeviceAccountLockEntity> lockOpt =
                deviceLockRepository.findByDeviceIdAndAppType(deviceId, appType);

        if (lockOpt.isPresent()) {
            DeviceAccountLockEntity lock = lockOpt.get();

            return lock.getEmail().equals(email);
        }

        boolean emailAlreadyExists = writerRepository.findByEmail(email).isPresent();

        return !emailAlreadyExists;
    }
}