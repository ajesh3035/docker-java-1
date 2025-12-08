# Deploying a Java WAR Application on Apache Tomcat (Ubuntu EC2)

This guide provides a step-by-step process for deploying a Java Web Application (WAR file) onto an Apache Tomcat Server running on an AWS EC2 Ubuntu instance.

## Prerequisites

Before you begin, ensure you have the following:

  * **AWS EC2 Ubuntu** (22.04+) instance ready.
  * **Security Group** configured with the following inbound rules:
      * Port **22** → SSH (for remote access)
      * Port **8080** → Tomcat (for application access)
      * Port **80** → Optional (if using a reverse proxy like Nginx)
  * **Java 17+** is available (we will install it).
  * Your `app.war` file ready for deployment.

-----

## Deployment Steps

### 1\. Update Server

Start by ensuring your server's package list is up-to-date and all existing packages are upgraded.

```bash
sudo apt update && sudo apt upgrade -y
```

### 2\. Install Java 17

Tomcat 10 requires Java 17 or newer. Install the OpenJDK package.

```bash
sudo apt install openjdk-17-jdk -y
```

**Verify Installation:**

```bash
java -version
```

### 3\. Download & Install Tomcat 10

Download the Tomcat 10 archive, extract it to the `/opt` directory, and rename the folder for simplicity.

```bash
cd /opt
sudo wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.49/bin/apache-tomcat-10.1.49.tar.gz
sudo tar -xvzf apache-tomcat-10.1.49.tar.gz
sudo mv apache-tomcat-10.1.49 tomcat10
sudo rm apache-tomcat-10.1.49.tar.gz
```

### 4\. Give Permissions

Set the appropriate file permissions and ownership so the `ubuntu` user can manage the Tomcat installation without needing `sudo` every time.

```bash
sudo chmod -R 755 /opt/tomcat10
sudo chown -R ubuntu:ubuntu /opt/tomcat10
```

### 5\. Start Tomcat Server

Navigate to the binary directory and start the server.

```bash
cd /opt/tomcat10/bin
./startup.sh
```

**Verify Access in Browser:**

Open your browser and navigate to:

```
http://<EC2-PUBLIC-IP>:8080
```

You should see the Apache Tomcat default page.

### 6\. Deploy the WAR File

Copy your compiled WAR file into the `webapps` directory of your Tomcat installation. Tomcat will automatically deploy it.

```bash
sudo cp /path/to/your-app.war /opt/tomcat10/webapps/
```

**Check Deployment:**

List the contents of the `webapps` directory. Tomcat automatically extracts the WAR file into a directory of the same name.

```bash
ls /opt/tomcat10/webapps
```

You should see both the extracted directory and the WAR file:

```
your-app/
your-app.war
```

### 7\. Restart Tomcat (Important)

A restart often ensures that the application is loaded correctly, especially after manual deployment.

```bash
cd /opt/tomcat10/bin
./shutdown.sh
./startup.sh
```

### 8\. Access Your Application

Access your deployed application using your EC2 Public IP, the Tomcat port (`8080`), and the name of your application directory (derived from the WAR file name).

```
http://<PUBLIC-IP>:8080/your-app/
```

**Example:**

```
http://44.210.15.172:8080/dptweb-1.0/
```

### 9\. Fix JSP Navigation Issues (If Applicable)

If you encounter navigation issues with JSPs, ensure that your links explicitly include the `.jsp` extension.

**Correct JSP Links:**

```html
<a href="login.jsp">Login</a>
<a href="register.jsp">Register</a>
```

### 10\. View Tomcat Logs

To troubleshoot issues during startup or runtime, monitor the primary Tomcat log file.

```bash
tail -f /opt/tomcat10/logs/catalina.out
```

### 11\. Tomcat Control Commands

For quick reference, here are the control commands:

| Action | Command |
| :--- | :--- |
| **Start** | `/opt/tomcat10/bin/startup.sh` |
| **Stop** | `/opt/tomcat10/bin/shutdown.sh` |

### 12\. Tomcat Folder Structure

Understanding the key directory structure can help with configuration and deployment.

```
/opt/tomcat10
 ├── bin/       # Startup/shutdown scripts
 ├── conf/      # Server configuration files (e.g., server.xml)
 ├── logs/      # Log files (e.g., catalina.out)
 ├── webapps/   # The deployment folder
      ├── your-app/
      └── your-app.war
```

-----

## Successfully Deployed

Your Java Web App is now running on Apache Tomcat 10 in an AWS EC2 Ubuntu instance\!

