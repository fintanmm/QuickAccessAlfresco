## Quick Access Alfresco

- ### Setting up a development environment

    The main function of QAA is to integrate Alfresco with the filesystem. On Windows, a custom certificate must be created for the Invoke-WebRequest command to work with a secure protocol.

        windows sdk has the cert creation utility
        base.net framework 4 is required
        more recent .net framework 4 versions must be uninstalled
        2010 redistributables must be uninstalled
        windows sdk can now be installed
        .net framework must be updated to at least 4.5 for powershell

- ### Integrate Build System

    In order to improve the development process, adding a build system was determined to be the best solution for QAA. Psake is a domain specific language used to create builds using a dependency pattern. Written in Powershell, Psake has the advantage of supporting native integration with QAA. It allows developers to define tasks and related dependencies, which are then executed as functions.

    Using Psake for QAA has the following advantages:
    - It provides a single entry point for testing the script
    - It allows the developer to specify certain rules for automating time-consuming tasks such as formatting the code
    - It can be configured for multiple environments and builds

- ### Scheduled Task

    QAA achieves seamless mapping of Alfresco to Windows Explorer. To ensure that any changes to Alfresco are reflected in Windows without too much delay, the chosen solution is to schedule the script to run and update the links to sites recurrently.
    
    Powershell on Windows 7 has certain limitations even when upgraded to the latest version. The current version of QAA relies on an additional Windows tool named 'schtask' to create and manage a scheduled task. This is not the ideal solution as 'schtask' is not native to PowerShell.

    As the script must function on Windows 7 there is currently no way to use the 'Scheduled Task' native module on PowerShell 3.0, which requires Windows 8 or newer.

- ### Windows 10 Enterprise

    A bug has been identified with QAA on a specific operating system. To be able to debug it a virtual environment must be set-up with Windows 10 Enterprise.

    Vagrant allows building and maintaining portable virtual environments for software development. It has a strong focus on automation, greatly reducing the environment set-up time. It also provides integration with another open-source tool, 'Packer', developed by the same company.
    
    Packer fully automates the creation of virtual machines by using configuration files. All the software is installed and configured when the image and built to provide improved stability. Images can also be fully tested to ensure that it will function properly each time it is launched.

    To access currently running machines Vagrant provides a secure shell command which will use the local SSH client. For Windows installations, a client is provided by default with the image. PowerShell remoting is also supported.