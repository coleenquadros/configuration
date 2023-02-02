# Manually Reproducing Edge Management Image and Inventory Performance Issues
The purpose of this document is to provide instructions on the functionality of Edge Management to reproduce issues that might arise during customer use of application.

## Edge Management Application Functionality
This section is an introduction to the major functions of the Edge Management application and will be helpful when chasing down issues specific to one or more areas.

### Building Images
To attempt to reproduce image build issues, follow the steps in the [Building a RHEL image](https://access.redhat.com/documentation/en-us/edge_management/2022/html/create_rhel_for_edge_images_and_configure_automated_management/proc-rhem-build-image) section of the Red Hat Edge management documentation.

### RHC Automatic Registration
Registration issues can be manually reproduced via the steps in the [Configuring automatic registration and management](https://access.redhat.com/documentation/en-us/edge_management/2022/html/create_rhel_for_edge_images_and_configure_automated_management/proc-rhem-auto-reg) section of the Red Hat Edge management documentation.

Use the ISO described in the documentation linked above to install on a VM or Baremetal system via traditional RHEL installation methods.

### Installing an Edge ISO on a system
You can use traditional RHEL installation methods to install an Edge ISO on baremetal or VM. For example, using [Cockpit](https://www.redhat.com/sysadmin/intro-cockpit) or via command-line using [virt-install](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/configuring_and_managing_virtualization/index).

### Updating Images
Image updates can be manually created via the UI by following the steps in the [Updating an image](https://access.redhat.com/documentation/en-us/edge_management/2022/html/create_rhel_for_edge_images_and_configure_automated_management/proc-rhem-update-image) section of the Red Hat Edge management documentation.

### Updating Systems
Updating the system with a new image is described in the [Updating a system](https://access.redhat.com/documentation/en-us/edge_management/2022/html/create_rhel_for_edge_images_and_configure_automated_management/proc-rhem-update-system) section of the Red Hat Edge management documentation.

# Manually troubleshooting issues
To troubleshoot an issue, the Engineering team typically manually runs through the end-to-end process--and if necessary pulls data from the web browser dev tools to inject into a curl command for repeated use at the command-line or in a script.

Curl commands to reproduce API calls for plugging into for-loops or scripts can be generated via the [API docs "Swagger" UI page](https://console.redhat.com/docs/api/edge/v1)

For example, to troubleshoot the listing of images, use the "Try It Out" button for the [GET /images section](https://console.redhat.com/docs/api/edge/v1#operations-default-listImages) of the UI. When the form is submitted, it will return the corresponding curl command (including token information) along with the result.

e.g., 

`
curl -X 'GET' \
  'https://console.redhat.com/api/edge/v1/images' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer [TOKEN REDACTED]'
`

See individual SOPs for specific examples of Edge Management application issues as they come up and the commands to go with them.
