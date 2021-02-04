# Get access to cico Jenkins slave

To get SSH access to a cico Jenkins slave (slave04, running OSIO jobs on https://ci.centos.org), do the following:

1. Sign in or create a new account at https://bugs.centos.org.

2. Create a new issue (`Report Issue`):
    
    2.1. Select Project: `CentOS CI`
    
    2.2. Reproducibility: `N/A`

    2.3. Severity: `minor`

    2.4. Priority: `normal`
    
    2.5. Summary: `Access to Jenkins slave slave04`
    
    2.6. Description:
    ```
    Hello, I am a member of the App SRE team in the Service Delivery organization at Red Hat.
    
    I would like to get access to slave04.ci.centos.org (by using jump.ci.centos.org).
    My Red Hat user name is: <my_kerberos_name>
    My public SSH public key is:
    ssh-rsa ...
    
    Thanks in advance,
    ```

    Example: https://bugs.centos.org/view.php?id=16772

3. Ask someone in the AppSRE team that already has access granted, to +1 this request. For example kbsingh or jmelis.

4. Update your ssh config:

    ```yaml
    Host centos-ci    
        Hostname slave04.ci.centos.org    
        User devtools    
        ProxyCommand ssh -q <my_kerberos_name>@jump.ci.centos.org nc %h %p 2>/dev/null 
    ```

5. `ssh centos-ci` - and you're in!

6. To SSH into a duffy node, grab the duffy node's IP from a Jenkins build log and run:

    ```sh
    $ ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no <duffy_node_ip> -l root
    ```
