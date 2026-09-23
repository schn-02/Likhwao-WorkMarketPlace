package com.example.likhwao.Services.USER;

import com.example.likhwao.Entity.DeviceAccountLockEntity;
import com.example.likhwao.Entity.USER.UserDetailsEntity;
import com.example.likhwao.Model.AuthModel;
import com.example.likhwao.Repository.DeviceAccountLockRepository;
import com.example.likhwao.Repository.USER.UserDetailsEntityRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.Optional;

@Service
public class UserDetailsServices {

    private final UserDetailsEntityRepository userRepository;
    private final DeviceAccountLockRepository deviceLockRepository;

    @Autowired
    public UserDetailsServices(
            UserDetailsEntityRepository userRepository,
            DeviceAccountLockRepository deviceLockRepository
    ) {
        this.userRepository = userRepository;
        this.deviceLockRepository = deviceLockRepository;
    }

    @Transactional
    public void saveUser(AuthModel dto) {

        String appType = "USER_APP";

        /*
         * Step 1:
         * Check device lock.
         * Same device + USER_APP par agar dusra firebaseUid hai,
         * to account create/login block kar do.
         */
        Optional<DeviceAccountLockEntity> existingDeviceLock =
                deviceLockRepository.findByDeviceIdAndAppType(dto.getDeviceId(), appType);

        if (existingDeviceLock.isPresent()) {
            DeviceAccountLockEntity lock = existingDeviceLock.get();

            if (!lock.getFirebaseUid().equals(dto.getFirebaseUid())) {
                throw new RuntimeException("This device is already linked with another user account");
            }
        }

        /*
         * Step 2:
         * Agar same firebaseUid se user already exist hai,
         * to duplicate user create mat karo.
         */
        Optional<UserDetailsEntity> existingUserByUid =
                userRepository.findByFirebaseUid(dto.getFirebaseUid());

        if (existingUserByUid.isPresent()) {
            UserDetailsEntity existingUser = existingUserByUid.get();

            existingUser.setEmail(dto.getEmail());
            existingUser.setName(dto.getName());
            existingUser.setCountryCode(dto.getCountryCode());
            existingUser.setCountryName(dto.getCountryName());
            existingUser.setPhoneNumber(dto.getPhoneNumber());
            existingUser.setEmailVerified(dto.isEmailVerified());
            existingUser.setDetailsCompleted(dto.isDetailsCompleted());
            existingUser.setRole("USER");

            userRepository.save(existingUser);

            /*
             * Same user hai, device lock already ho sakta hai.
             * Agar nahi hai, to create kar do.
             */
            if (existingDeviceLock.isEmpty()) {
                createDeviceLock(dto, appType);
            }

            return;
        }

        /*
         * Step 3:
         * Email already kisi aur firebaseUid ke saath exist hai to block.
         */
        Optional<UserDetailsEntity> existingUserByEmail =
                userRepository.findByEmail(dto.getEmail());

        if (existingUserByEmail.isPresent()) {
            throw new RuntimeException("This email is already registered with another account");
        }

        /*
         * Step 4:
         * New user create karo.
         */
        UserDetailsEntity entity = new UserDetailsEntity();

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
        entity.setRole("USER");

        userRepository.save(entity);

        /*
         * Step 5:
         * Device lock create karo.
         */
        if (existingDeviceLock.isEmpty()) {
            createDeviceLock(dto, appType);
        }

        System.out.println("User saved successfully");
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

    public Map<String, Object> checkUser(String deviceId, String firebaseUid) {

        String appType = "USER_APP";

        Optional<UserDetailsEntity> userOpt =
                userRepository.findByFirebaseUid(firebaseUid);

        Optional<DeviceAccountLockEntity> lockOpt =
                deviceLockRepository.findByDeviceIdAndAppType(deviceId, appType);

        boolean userExists = userOpt.isPresent();

        boolean deviceMatches = lockOpt
                .map(lock -> lock.getFirebaseUid().equals(firebaseUid))
                .orElse(false);

        boolean emailVerified = userOpt
                .map(UserDetailsEntity::isEmailVerified)
                .orElse(false);

        boolean detailsCompleted = userOpt
                .map(UserDetailsEntity::isDetailsCompleted)
                .orElse(false);

        boolean blocked = userOpt
                .map(UserDetailsEntity::getBlocked)
                .orElse(false);

                boolean deviceMatched = lockOpt
        .map(lock -> lock.getFirebaseUid().equals(firebaseUid))
        .orElse(false);

boolean deviceLockedByOtherAccount = lockOpt
        .map(lock -> !lock.getFirebaseUid().equals(firebaseUid))
        .orElse(false);

      return Map.of(
        "userExists", userExists,
        "deviceMatched", deviceMatched,
        "deviceLockedByOtherAccount", deviceLockedByOtherAccount,
        "emailVerified", emailVerified,
        "detailsCompleted", detailsCompleted,
        "blocked", blocked
);
    }

    public boolean canCreateAccount(String deviceId, String email) {

        String appType = "USER_APP";

        /*
         * Device agar already kisi USER_APP account ke saath locked hai,
         * to new email allow nahi karni.
         */
        Optional<DeviceAccountLockEntity> lockOpt =
                deviceLockRepository.findByDeviceIdAndAppType(deviceId, appType);

        if (lockOpt.isPresent()) {
            DeviceAccountLockEntity lock = lockOpt.get();

            return lock.getEmail().equals(email);
        }

        /*
         * Email already exist hai to normally create account allow nahi hoga.
         */
        boolean emailAlreadyExists = userRepository.findByEmail(email).isPresent();

        return !emailAlreadyExists;
    }
}