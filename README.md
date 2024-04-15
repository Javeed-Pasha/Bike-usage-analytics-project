# Bike usage analytics project

- [Project Description](#project-description)

- [Prerequisites](#prerequisites)

- [Setting up GCP](#setting-up-gcp)

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

##   Setting up and Reproducibility

*Note: these instructions are used for Linux/WSL.

### 1. Clone the Repository
	```
		git clone <repository_url>  <repository_directory>
	```
### 2. Install and initialize google cloud SDK
	```bash
		sudo apt-get update && sudo apt-get install google-cloud-sdk
		gcloud init
	```
	
### 3. Install  and initialize and download Terraform
	```bash
		sudo apt update && sudo apt install terraform 
		terraform init
	```
### 4. Create and download service account key

Create [Service Account key](https://cloud.google.com/iam/docs/keys-create-delete)

ensure the service account key as following permissions.

`Artifact Registry Reader,Artifact Registry Writer,BigQuery Admin,Cloud Run Developer,Cloud SQL Admin,Compute Admin,Dataproc Administrator,Service Account Token Creator,Storage Admin`

download the service account key and save as `my-creds.json` and save it in your local machine under `~/.gc/` directory. This key file will be used to authenticate requests to GCP services

### 5. Set Google Application Credentials
	```
		export GOOGLE_APPLICATION_CREDENTIALS=~/.gc/my-creds.json 
		gcloud auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS
	```
	
### 6. Create SSH Key
	```
		ssh-keygen -t rsa -f ~/.ssh/KEY_FILENAME -C USERNAME -b 2048
	```
		this user will be used to login to the new GCP VM we will create in next steps.
		
### 7. Update Terraform Configuration
		In the Terrafom files cloned in previous step go to varaibles.tf 
    1.   in **variables.tf** file
          Replace 
				1.  Set the `VM_USER_HOME` value to `/home/USERNAME`, replacing `USERNAME` with the username specified during SSH key generation
        2.  set `project` to your gcp project_id 
        3.  set `bq_dataset` to your bigQuery dataset name 
        4.  set `gcs_bucketname` to your gcp bucket name
    2.  In **main.tf** file
        1.  replace the string `ssh-keys = "jpasha:${file("~/.ssh/id_rsa.pub")}"`
							with `ssh-keys = "<USERNAME>:${file("~/.ssh/id_rsa.pub")}"`
							  where USERNAME which is given in ssh-keygen step 6

### 8. Deploy Infrastructure
	```bash
		terraform plan 
		terraform apply
	```
 The Terraform script provisions a Google Cloud Platform (GCP) virtual machine (VM) and fetches the Mage git repository, which contains the Mage data pipeline to extract the MiBici data into GCS bucket and into bigQuery.
	
### 9. Use VS Code Remote SSH Extension
	Connect to your remote VM using VS Code with the Remote - SSH extension. Open VS Code, press `F1`, and select `Remote-SSH: Connect to Host...`. Enter the SSH connection details for your VM.
	
	By this time the new GCP VM will have a running mage docker .  
	
### 10. Update File Ownership and add user to docker group 
	```bash
		sudo chown -R $USER:$USER mage
		sudo usermod -a -G docker $USER
	```
	 
### 11. temporarily switch to docker  so that you dont get  permissions issue
	```bash
		newgrp docker
	```
	
### 12.  Copy Service Account Key
		Copy your service account key contents to below file
	```bash
		touch /home/$USER/.gc/my-creds.json 
	```
 manually copy  YOUR_GCP_CREDENTIALS.json /home/$USER/.gc/my-creds.json
			
	
### RUN the PIPELINE

To begin, navigate to the directory containing the Mage project by executing cd ~/mage in your terminal. Then, start the Docker containers in detached mode with the command docker-compose up -d. Ensure that you configure port forwarding in VS Code for ports 6789 and 5432. You can access the Mage application at http://localhost:6789/.

Additionally, please note that you may need to adjust certain parameters such as bucket_name, project_id, and bigquery dataset names in the Mage pipelines according to your setup.

Finally, run the pipeline named DataPipeline_mibici to initiate the data processing tasks
    
12. Time to work with mage. Go to the browser, find **pipelines**, click on air_quality_api pipeline and click on Run@once.

  

<table><tr>

<td> <img src="images/mage-find-pipelines.png" width="150"/> </td>

<td> <img src="images/pipeline-name.png" width="350"/> </td>

<td> <img src="images/run-pipeline.png" width="250"/> </td>

<tr>

<td>Find pipeline</td>

<td>Pipeline </td>

<td>Run pipeline </td>

</tr>

</tr></table>

  
  

**IMPORTANT**: For some reason, an error may occur during the step of creating the 'air_aggregated' table, indicating '404 Not Found: Table air-quality-project-417718:air_quality.air_aggregated_data was not found in location EU.' However, if you navigate to BigQuery and refresh the database, the table should appear.

  

When you are done, in a google bucket you should have two CSV files and in the BigQuery you should have all tables. Your pipeline should look like this:

  
  

<img src="images/mage-workflow.png" width="450" />

<br>

<br>

  

## Creating Visualisations

  

- With your google account, log in at [Google looker studio](https://lookerstudio.google.com/navigation/reporting)

  

- Connect your dataset using the Big Query Connector

  

- Select your project name then select the dataset. This would bring you to the dashboard page

  

- Create your visualizations and share.

  

<br>

  

### Facts about Pollen

  

A pollen count is the measurement of the number of grains of pollen in a cubic meter of air. High pollen counts can sometimes lead to increased rates of allergic reactions for those with allergic disorders.

  

Pollen, a fine to coarse powdery substance, is created by certain plants as part of their reproduction process. It can appear from trees in the spring, grasses in the summer, and weeds in the fall. Interestingly, pollen from flowers doesn’t usually contribute to nasal allergy symptoms.

  

<img src="images/pollen-counts-scale.png" width="450" />

  

---

  

As a general observation, most aeropalynology studies indicate that temperature and wind have a positive correlation with airborne pollen concentrations, while rainfall and humidity are negatively correlated.

  

---

### Air Quality and Pollen.

  

Urban areas tend to have lower pollen counts than the countryside, but pollen can combine with air pollution in the city center and bring on hay fever symptoms. It’s not just in the summer months either; it can peak as early as April and May.

  

<img src="images/airquality-counts-scale.png" width="450" />

  

<br >

  

<table><tr>

<td> <img src="images/airquality-report.png" width="450"/> </td>

<td> <img src="images/weather-airquality-report.png" width="450"/> </td>

<tr>

<td>Air Quality Report 1</td>

<td>Air Quality Report 2</td>

</tr>

</tr></table>

  
  

[Home](#air-quality-project)
