# AWS MFA Entity Already Exists

## Error

![](images/MFAEntityAlreadyExists.gif)

When an IAM user tries to create an MFA device and they click cancel or the session times out they can get `Entity Already Exists` error. The MFA device is still assigned to the user but not synced properly. So when the user tries to create another virtual MFA device it fails with the error Entity Already Exists. Note that the MFA device will not be listed in UI even if it is assigned.

## Resolution

Login into the AWS account as administrator and temporarily assign MFA to the user facing the issue. Once the MFA is assigned successfully, remove it. Now the user will be able to configure MFA for their IAM user.
