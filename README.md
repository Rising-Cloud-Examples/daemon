# daemon
This guide will walk you through the simple steps needed to build a Daemon on Rising Cloud, which tracks the seconds passed since the Worker handling the request has spun up.

# 1. Install the Rising CloudCommand Line Interface (CLI)
In order to run the Rising Cloud commands in this guide, you will need to install the Rising Cloud Command Line Interface. This program provides you with the utilities to setup your Rising Cloud Task or Rising Cloud Web Service, upload your application to Rising Cloud, setup authentication, and more. If you haven’t already, [click here](/docs/install) to for instructions to install Rising Cloud CLI.

# 2. Login to Rising Cloud Using the CLI
Using a command line console (called terminal on Mac OS X and command prompt on Windows) run the Rising Cloud login command. The interface will request your Rising Cloud email address and password.

```risingcloud login```

# 3. Initialize Your Rising Cloud Task

Whether this is an existing project or a new project, unless you desire it to be a web task, you must initialize it as a Rising Cloud Task.

Navigate to or create a directory for your project and run the following command replacing $TASK with your unique task name.

Your unique task name must be at least 12 characters long and consist of only alphanumeric characters and hyphens (-). This task name is unique to all tasks on Rising Cloud. A unique URL will be provided to you for sending jobs to your task.

If a task name is not available, the CLI will return with an error so you can try again.

```risingcloud init -s $TASK```

This creates a **risingcloud.yaml** file in your project directory. This file can be used to configure the build script.

# 4. Create Your Scripts

**Writing your daemon**

For this example, we’ll create a daemon which tracks the seconds passed since the Rising Cloud Worker handling the request has spun up. 

In your project directory, create a file called **daemon.sh** and past the following code in it:

```
start=$SECONDS

while true; do
    duration=$((SECONDS - start));
    echo "Time since start: $duration" > time.txt;
    sleep 1;
done
```

This script writes the seconds passed since the start of the script, then waits a second, repeating indefinitely.

**Writing your program**

You will need a way to read the output. Create a file called **runme.sh** in your project directory and paste the following:

```
timestr=$( cat time.txt )
echo "{\"time\": \"$timestr\"}" > response.json
```

This script reads time.txt and outputs is contents in a time field in a JSON string, then puts this string in a new file called response.json. Note: This example was created for ease of creation and execution. It is possible that the file is read as it is being written to, and this may cause an incomplete result. If using daemons for a similar purpose, be sure to use a mutex locking mechanism before opening the file with either script.

**Editing your Rising Cloud configuration file**

Open the previously created risingcloud.yaml file and add the edit the following steps:
```
deps: 
- chmod +x runme.sh
- chmod +x daemon.sh
daemons: 
- bash -c ./daemon.sh
run: bash -c ./runme.sh
```

# 5. Build and Deploy Your Rising Cloud Task

Use the push command to push your updated risingcloud.yaml to your Task on Rising Cloud.

```risingcloud push```

Use the build command to zip, upload, and build your app on Rising Cloud.

```risingcloud build```

Use the deploy command to deploy your app as soon as the build is complete.  Change $TASK to your unique task name.

```risingcloud deploy $TASK```

Alternatively, you could also use a combination to push, build and deploy all at once.

```risingcloud build -r -d```

Rising Cloud will now build the infrastructure necessary to run and scale your application including networking, load balancing and DNS.  Allow DNS a few minutes to propogate and then your app will be ready and available to use!

# 6. Queue Jobs for Your Rising Cloud Task

**Send jobs to your new app**

- Log into your Rising Cloud Team: <u>[https://my.risingcloud.com/](https://my.risingcloud.com/)</u>
- Select your task from the Dashboard.
- Click on Jobs in the left menu.
- Click New Job Request.  
- Send a blank request to your task, leave the curly brackets.

```{ }```

Rising Cloud will take a few moments to spin-up your app, and proces your request.  In the future it will learn from the apps usage patterns to anticipate usage, making instances available in advance of need, while also spinning down instances when not needed.  

Click the twisty to open up your Job, and then click Arguements to see your Hello World output

```^```

**Alternatively** you can use an API testing tool such as Postman or Insomnia

POST HTTP request, choose body type JSON:

```https://{your_task_url}.risingcloud.app/risingcloud/jobs```

Within the body of the POST type and SEND: 

```{ }```

This should yield an HTTP response with a body that looks like:

```{“jobId”: “{id of job}”}```

To get the results of the job, make a GET HTTP request to your task:

```https://{your_task_url}.risingcloud.app/risingcloud/jobs/{id of job}```

This should respond with a JSON object in the response body. As this example script is extremely fast and simple, the job should complete before you send this request. You can verify this by checking whether the status field in the response JSON is “Completed” and Time since start contains a number greater than 0.  Send a couple more jobs, and you'll see the time increase in the subsequent job results.

```	
"status": "Completed"
"time": "Time since start: #"
```

Congratulations, you’ve successfully created and used your Rising Cloud application with Daemons!
