# Bike usage analytics project

- [Project Description](#project-description)

- [Prerequisites](#prerequisites)

- [Setup and Reproducibility](#Setup-and-Reproducibility)

- [Running the Code](#running-the-code)

- [Creating Visualisations](#creating-visualisations) 


<img src="images/project-gif.svg" width="650" />


## Project Description

This project aims to build an end-to-end data engineering pipeline for processing and analyzing data from the [MiBici](https://www.mibici.net/es/datos-abiertos/) public bicycle system in the Guadalajara Metropolitan Area. The pipeline developed using [Mage](https://docs.mage.ai/introduction/overview) involves downloading open data from the MiBici website, storing it in a Google Cloud Storage ( ([GCS](https://cloud.google.com/)) bucket, transforming the data using [Apache Spark](https://spark.apache.org/docs/2.1.0/api/python/index.html), and loading it into Google [BigQuery](https://cloud.google.com/bigquery/) for visualization and analysis.

The project was developed as the final assignment for the [Data Engineering Zoomcamp](https://github.com/DataTalksClub/data-engineering-zoomcamp#data-engineering-zoomcamp) in the 2024 Cohort.

The application fetches data from the [MiBici](https://www.mibici.net/es/datos-abiertos/). from 2020 .

  

**Pipeline description:**

The Pipelines are orchestrated via  [Mage](https://docs.mage.ai/introduction/overview)

- Pipeline fetches the data from APIs

- Then it transforms both data sets and uploads them to Google Cloud Storage.

- In the next step this data is loaded from GCS into BigQuery.

- from BigQuery dataset we analyzing and visualizing bicycle usage patterns and trends using Tableau or other visualization tools..


---

## Prerequisites


Before running the data engineering pipeline, ensure you have:

1. [Docker](https://docs.docker.com/engine/install/)

2. [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

3. [Terraform](https://developer.hashicorp.com/terraform/install)

4. [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)

5. [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

6. [VS Code](https://code.visualstudio.com/download) with the [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) extension installed
  
7. Setup a GCP account

To run the code you need to follow the steps below.

---

##   Setup and Reproducibility

*Note: these instructions are used for Linux/WSL.

### 1. Clone the Repository
	
		git clone https://github.com/Javeed-Pasha/Projecttest.git terraform_test/
	
### 2. Install and initialize google cloud SDK
	
		sudo apt-get update && sudo apt-get install google-cloud-sdk
		gcloud init
	
	
### 3. Install  and initialize and download Terraform
	
		sudo apt update && sudo apt install terraform 
		terraform init
	
### 4. Create and download service account key

Create [Service Account key](https://cloud.google.com/iam/docs/keys-create-delete)

ensure the service account key as following permissions.

`Artifact Registry Reader,Artifact Registry Writer,BigQuery Admin,Cloud Run Developer,Cloud SQL Admin,Compute Admin,Dataproc Administrator,Service Account Token Creator,Storage Admin`

download the service account key and save as `my-creds.json` and save it in your local machine under `~/.gc/` directory. This key file will be used to authenticate requests to GCP services

### 5. Set Google Application Credentials
	
		export GOOGLE_APPLICATION_CREDENTIALS=~/.gc/my-creds.json 
		gcloud auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS
	
	
### 6. Create SSH Key
	
		ssh-keygen -t rsa -f ~/.ssh/gcp_key -C gcp -b 2048
		#here gcp_key is keyfilename and gcp is the username 	
		this user will be used to login to the new GCP VM we will create in next steps.
		
### 7. Update Terraform Configuration
		In the Terrafom files cloned in previous step go to varaibles.tf 
    1.   In **variables.tf** file Replace 
	1.  If the SSH key is generated with a username other than "gcp", you should set the VM_USER_HOME value to /home/USERNAME in the Terraform configuration file. 
 	    Replace USERNAME with the actual username specified during SSH key generation.
        2.  set `project` to your gcp project_id 
        3.  set `bq_dataset` to your bigQuery dataset name 
        4.  set `gcs_bucketname` to your gcp bucket name
    2.  In **main.tf** file. If the username is the same as "gcp", you don't need to make any changes mentioned below.
    	1.  replace the string `ssh-keys = "gcp:${file("~/.ssh/gcp_key.pub")}"`
	    with `ssh-keys = "<USERNAME>:${file("~/.ssh/KEYFILENAME.pub")}"` 
     	    Replace <USERNAME> with the actual username and KEYFILENAME with the filename specified during step 6 of the SSH key generation process.

### 8. Deploy Infrastructure
The Terraform scripts provisions a Google Cloud Platform (GCP) virtual machine (VM) and fetches this [Mage git repository](https://github.com/Javeed-Pasha/mage_dataengineeringzoomcamp), which contains the Mage data pipeline to extract the MiBici data into GCS bucket and into BigQuery warehouse.

**IMPORTANT**: The only thing that can **fail** in terraform apply are due to gcp bucket name  and bigquery dataset name. 
In case the creation of the GCP bucket and BigQuery dataset fails during the Terraform execution due to name conflicts,you'll need to choose new names and rerun the terraform plan and terraform apply steps.. 
	
		terraform init
  		terraform plan
		terraform apply
	
 
	
### 9. Use VS Code Remote SSH Extension
Connect to your remote VM using VS Code with the Remote - SSH extension. Open VS Code, press `F1`, and select `Remote-SSH: Connect to Host...`. 
Enter the SSH connection details for your VM.
	
By this time the new GCP VM will have a running mage docker .  
	
### 10. Update File Ownership and add user to docker group 
	
		sudo chown -R $USER:$USER mage
		sudo usermod -a -G docker $USER
	
	 
### 11. temporarily switch to docker  so that you dont get  permissions issue
	
		newgrp docker
	
	
### 12.  Copy Service Account Key
Copy your service account key contents to below file
	
		mkdir -p /home/gcp/.gc/
		touch /home/gcp/.gc/my-creds.json
 
	
 manually copy  YOUR_GCP_CREDENTIALS.json  to  ~/.gc/my-creds.json on new GCP VM .
			
### Running the Code

1.	To begin, navigate to the directory `cd ~/mage` in your terminal. Then, start the Docker containers `docker-compose up -d`. 
2.	Ensure that you configure port forwarding in VS Code for ports 6789 and 5432.
3.	Now, you can access the Mage application at http://localhost:6789/.
4.	Edit the pipeline named **DataPipeline_mibici** and goto block named **create_spark_session** and replace the variables
		bucket_name='REPLACE_WITH_GCP_BUCKETNAME'
		project_id = 'REPLACE_WITH_GCP_PROJECT_ID'
		bigquery_dataset = 'REPLACE_WITH_BIGQUERY_DATASETNAME'
5.	Finally, run the pipeline named DataPipeline_mibici to initiate the data processing tasks
 
Your pipeline should look like this:
   
<img src="images/mage_flow.PNG" width="900" height="550" />

Once the process is complete, the raw data for rides will be partitioned by year and month and stored in Google Cloud Storage under the directory **bucket_name/raw/rides/\*/\*/**. 
Similarly, the raw data for stations will be located at **bucket_name/raw/nomenclature/\***.

In BigQuery, you will find a Dimension table named **Dim_Stations**, a Fact table called **Rides_Fact**, and an Analytics table named **rides-analytics_data**. The analytics table will contain metrics such as ride routes to identify popular routes.


<br>

<br>

  

## Creating Visualisations

  

- Log in to [Google looker studio](https://lookerstudio.google.com/navigation/reporting)

- Connect your dataset using the Big Query Connector

- Select your project name and the dataset. This would launch a dashboard page

- Create your visualizations and share.

  

<br>


<br >



[Top](#Bike-usage-analytics-project)
