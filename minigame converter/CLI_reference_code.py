#This CLI will allow you to perform various operations with PAPI (Property Manager API)

#Author: Andrew Loebach


#v1 - Initial version
#Author: Andrew Loebach 

### IMPORTING PACKAGES AND SETTING CREDENTIALS ###
import json
import sys
if sys.version_info[0] >= 3:
   from urllib.parse import urljoin
else:
   from urlparse import urljoin
from os.path import expanduser #added for importing credentials from .edgerc
from akamai.edgegrid import EdgeGridAuth, EdgeRc
import requests
import argparse


#Parse command-line arguments and set default values if no argument is specified
parser = argparse.ArgumentParser()
parser.add_argument("operation", help="type of operation: 'retrieve', 'upload', or 'activate'")
parser.add_argument("config", help="name of the configuration")
parser.add_argument("--switchkey", help="Account switch key")
parser.add_argument("--section", help="Section for .edgerc file", default="default")
parser.add_argument("-f", "--file", help="filename for download/upload")
parser.add_argument("--network", help="Specify network (PROD or STAGING)", default="STAGING")
parser.add_argument("-v", "--version", help="specifies config version")

parser.add_argument("--upload", action="store_true", help="Upload cloudlet policy in json format")
parser.add_argument("--download", action="store_true", help="Download cloudlet policy in json format")
parser.add_argument("--list", action="store_true", help="List cloudlet policies")
parser.add_argument("--activate", help="activates the configuration on STAGING or PROD")

args = parser.parse_args()

print("performing", args.operation, "on", args.config)


#################################################
### Reading API credentials from .edgerc file ###
#################################################
home = expanduser('~') #search for .edgerc file in root directory
EDGERC_PATH = '%s/.edgerc' % home 
edgerc = EdgeRc(EDGERC_PATH)
section = args.section #can replace with PAPI or other section if you prefer
baseurl = 'https://%s' % edgerc.get(section, 'host')

s = requests.Session()
s.auth = EdgeGridAuth.from_edgerc(edgerc, section)
#################################################


#####################################################################
#### RETRIEVING PROPERTY INFORMATION ###
#####################################################################
#pinfo_path = '/papi/v1/search/find-by-value' 
if args.switchkey:
   pinfo_path = '/papi/v1/search/find-by-value?accountSwitchKey=' + args.switchkey  #with accountSwitchKey as query parameter
else:
   pinfo_path = '/papi/v1/search/find-by-value'  #without SwitchKey as query parameter


pinfo_headers = {
    'Content-Type': 'application/json',
    'PAPI-Use-Prefixes': 'false'
}
pinfo_data = json.dumps(
{
    'propertyName': args.config
})

print('Retrieving property information...')

try:
    #API Call to retrieve version info
    pinfo_res = s.post(urljoin(baseurl, pinfo_path), headers=pinfo_headers, data=pinfo_data)
    pinfo_ = json.loads(pinfo_res.text)['versions']['items']
except:    #If the first API request fails print error message to check .edgerc file  
    print('ERROR reading .edgerc file')
    print('Please ensure that you have valid API credentials listed in the .edgerc file in the [', section, '] section', sep='')
    print('A valid .edgerc file should be located here:', EDGERC_PATH)
    sys.exit() #escape program if credentials are not successfully imported

print(pinfo_)

# Selects the config version
if args.network == "STAGING":
   for version in pinfo_:
      if version["stagingStatus"] == 'ACTIVE':
         pinfo = version
         break
elif args.network == "PROD":
   for version in pinfo_:
      if version["productionStatus"] == 'ACTIVE':
         pinfo = version
         break
else:
   pinfo = pinfo_[0] # selects latest inactive version is specified

if args.version:
	property_version =  args.version
else:
	property_version =  pinfo['propertyVersion']
	
print('Status code: ', pinfo_res.status_code)
print(pinfo_res.text)


##################################################################
##################   RETRIEVING PROPERTY JSON   ##################
##################################################################
if args.operation == "retrieve":
	
	print('Retrieving ', args.config, ' v', property_version, '...', sep='')
		
	# Path:    /papi/v1/properties/{propertyId}/versions/{propertyVersion}/rules{?contractId,groupId,validateRules,validateMode,dryRun}
	prule_path = '/papi/v1/properties/{0}/versions/{1}/rules?' \
            	'contractId={2}&groupId={3}'.format(pinfo['propertyId'],
               	property_version, pinfo['contractId'], 
               	pinfo['groupId'])
	
	if args.switchkey:
		prule_path = prule_path + '&accountSwitchKey=' + args.switchkey 
	
	prule_res = s.get(urljoin(baseurl, prule_path))
	
	print('########## Property Rule Tree ##########')
	print('Retrieving property rule tree...')
	print('Status code: ', prule_res.status_code)
	#print(prule_res.text)
	prule = json.loads(prule_res.text)
	
	## Save the current version rule tree (json)
	if args.file:
		filename = args.file
	else:
		filename = args.config + "_v" + str(property_version) + '.json'
	
	with open(filename, 'w') as file:
		file.write(json.dumps(prule, indent=2))
	print('JSON saved to the file: ', filename)



##################################################################
####################   UPLOAD PROPERTY JSON   ####################
##################################################################
if args.operation == "upload":	
	
	#### READING PROPERTY JSON FROM FILE ###
	if args.file: #If filename is specified, read hostnames from file
			try:
				f = open(args.file, "r")
			except:
				print('ERROR: file cannot be read (', args.file , ')')
				sys.exit()
			#data = f.read().replace('\n',';').replace(',',';')
			#hostnames_list = data.split(';')
			property_json = f.read()
			
	else:
			print("ERROR: No file specified. Please specify the filename or the config JSON with -f <filename>")
			sys.exit()
	
	
	pcreate_path = '/papi/v1/properties/{0}/versions?contractId={1}&groupId={2}'.format(
                    	prodinfo['propertyId'], prodinfo['contractId'], prodinfo['groupId'])                    
	
	if args.switchkey:
		pcreate_path = pcreate_path + '&accountSwitchKey=' + args.switchkey 
	
	pcreate_headers = {
		'Content-Type': 'application/json',
		'PAPI-Use-Prefixes': 'false'
	}
	
	pcreate_data = json.dumps(
	{
		'createFromVersion': prod_version,
	})
	
	pcreate_res = s.post(urljoin(baseurl, pcreate_path),
								headers=pcreate_headers, data=pcreate_data)
	print('########## Property Create ##########')
	print('Creating new version of', prodinfo['propertyName'])
	print('Based on version:', prodinfo['propertyVersion'])
	print('...')
	print('Status code: ', pcreate_res.status_code)
	print(pcreate_res.headers)
	print(pcreate_res.text)
	pcreate = json.loads(pcreate_res.text)
	# extract version here
	if pcreate:
		pcreate_version = int(pcreate['versionLink'].rsplit('/', 1)[-1].rsplit('?', 1)[0])
	######################################
	
	
	######################################
	### UPLOAD JSON RULE TREE AND SAVE ###        
	######################################
	#pupdate = '/papi/v1/properties/{0}/versions/{1}/rules?' \
	#            'contractId={2}&groupId={3}'.format(prodinfo['propertyId'],
	#                pcreate_version, prodinfo['contractId'], 
	#                prodinfo['groupId'])
	
	#Use version above if you are not using an account SWITCH_KEY
	pupdate = '/papi/v1/properties/{0}/versions/{1}/rules?' \
		 		'contractId={2}&groupId={3}&accountSwitchKey={4}'.format(prodinfo['propertyId'],
			  		pcreate_version, prodinfo['contractId'], 
			  		prodinfo['groupId'],SWITCH_KEY)
							  		
	pupdate_header = {
		# 'Content-Type': 'application/vnd.akamai.papirules.v2017-06-19+json',
		'Content-Type': 'application/json',
		'PAPI-Use-Prefixes': 'false'
	}
	
	# API Call to upload working JSON config to production configuration
	pupdate_res = s.put(urljoin(baseurl, pupdate), 
						 		headers=pupdate_header, data=json.dumps(prule))
	print('########## Property Update ##########')
	print('Status code: ', pupdate_res.status_code)
	#print(pupdate_res.headers)
	#print(pupdate_res.text)
	
	if pupdate_res.status_code == 200:
		print('*** ',prodinfo['propertyName'], ' v', pcreate_version, ' created succesfully! ***', sep='')
	##################################################################


print("Script finished")
sys.exit()






##############################################################################################################################################
##################################
##################################
### BEGIN REFERENCE CODE #########
##################################
##################################


##################################
### Customer specific settings ###
##################################

#Account SWITCH_KEY for Akamai Professional Services (not needed for account-specific API clients)
#SWITCH_KEY = '1-6JHGX'  #Account SWITCH_KEY for Akamai Professional Services account
SWITCH_KEY = '1-5QD3T'  #Account SWITCH_KEY for Adidas AG account

## Define dev and target (e.g. prod) property names ##
STAGING_PROPERTY_NAME = 'www.staging.adidas.com.my'
PROD_PROPERTY_NAME = 'www.adidas.com.my'

#IMPORT_SOURCE_IS_STAGING = True # Defines if the JSON should be exported from the STAGING config and then imported to the PROD config
IMPORT_SOURCE_IS_STAGING = False # Defines if the JSON should be exported from the PROD config and then imported to the STAGING config

#VERSION = 'productionStatus' # selects version deployed on production network
VERSION = 'stagingStatus' # selects version deployed on staging network
TRY_TO_RETRIEVE_ACTIVE_VERSION = True # when retrieving the source version this flag controls if the active version should be used. If value is 'false', then the lates inactive version will be used
UPLOAD_JSON_TO_TARGET_CONFIG = False # set to True, if the modified JSON should be uploaded to the target config directly

KEEP_DEFAULT_RULE_SETTINGS = True # Set to true if you want to keep target config's default rule
KEEP_CLOUDLET_ORIGINS = True # Set to true if you want to keep the target config's cloudlet origins
KEEP_HYPE_SETTINGS = True # Set to true if you want to keep target config's HYPE setup rules


#------ Enter replacement settings into this list. The values are: ------------------
#------ 1: JSON Key, which value to be replaced -------------------------------------
#------ 2: Value in STAGING config  ----------------------------------------------------
#------ 3: Value in PROD config  -----------------------------------------------------
#------------------------------------------------------------------------------------
REPLACEMENT_SETTINGS = [

	#CP codes
	['id', 368470, 381253], # CP code in default rule
	['id', 368470, 381253], # CP code for HLP whitelisting failover
	['id', 605447, 605463], # CP code for PDP and HP Origin 
	
	#Edge Redirector Cloudlets
	['name', 'www_staging_grayling_adidas_com', 'www_grayling_adidas_com'],

	#Phased Release Cloudlets
	['name', 'staging_grayling_adidas_com_malaysia', 'www_m_grayling_adidas_com_malaysia'],
	['id', '134145','39932'],
	['label', 'staging_grayling_adidas_com_malaysia', 'my_new_dw_origin'],
		
	['name', 'PDP_stg_adidas_gralying', 'PDP_prod_adidas_grayling'],
	['id', '46504','54053'],
	
	#Request control cloudlet policies
	['name','Blocking_stag_adidas_ecom', 'Blocking_prod_adidas_ecom'],
	['id', '132128','91684'],
	
	#Visitor Prioritization Cloudlet
	# VP cloudlet is in the "HYPE" section, which we will leave in the respective configurations
	
	#Hostnames
	['values', 'www.staging.adidas.co.in', 'www.adidas.co.in'],
	['values', 'www.staging.adidas.com.vn', 'www.adidas.com.vn'],
	['values', 'www.staging.adidas.com.my', 'www.adidas.com.my'],
	['hostname', 'qa-adidasrunners.adidas.com', 'adidasrunners.adidas.com'],
	['hostname', 'hp.qa.brand.adidas.com', 'hp.brand.adidas.com'],

	#Origin Hostnames
	['hostname', 'origin.preview.campaign.adidas.com', 'origin.brand.campaign.adidas.com'],
	['hostname', 'staging-md-adidasgroup.demandware.net','commcloud.prod-bcbs-adidas-{{user.PMUSER_TLD}}.cc-ecdn.net'],

	#Failover Hostnames
	['cexHostname', 'failover-staging.adidas.com', 'failover-www.adidas.com'],	
	['xml', 'failover-staging.adidas.com', 'failover-www.adidas.com'],
	
	#path rewrites
	['value', '/staging/', '/production/'],	
	['targetPath', '/staging/product-assistant/', '/production/product-assistant/'],	
	['targetUrl', '/staging/index.html', '/prod/index.html'],	
	#['value', '/staging/glass/sitemaps/adidas/MY/', '/production/glass/sitemaps/adidas/MY/'],	
	#['value', '/staging/glass/sitemaps/adidas/VN/', '/production/glass/sitemaps/adidas/VN/'],	
	['value', '/staging/glass/sitemaps/adidas/', '/production/glass/sitemaps/adidas/MY/'],	
	['value', '/staging/glass/sitemaps/adidas/', '/production/glass/sitemaps/adidas/VN/'],	
	
	#Edgeworkers
	['edgeWorkerId', '4550','5158'], #Edgeworker ID for canary deployment 

   # Glass IP whitelist
   ['values',
   # Staging   
   ["34.249.205.218",
   "35.162.237.198",
   "13.229.188.167",
   "34.212.152.50",
   "52.215.167.166",
   "52.221.169.111",
   "52.211.138.4",
   "18.236.17.69",
   "108.128.189.209",
   "63.32.212.191",
   "18.200.182.70",
   "52.214.5.86",
   "63.34.186.185",
   "63.33.150.165",
   "82.112.169.24",
   "82.112.169.25",
   "82.112.169.26",
   "3.0.203.106",
   "3.0.10.205",
   "54.255.254.154",
   "100.21.149.24",
   "44.229.216.92",
   "52.12.92.158",
   "54.201.22.58"],
   
   # Production   
   ["34.249.205.218",
   "35.162.237.198",
   "13.229.188.167",
   "18.236.17.69",
   "52.221.169.111",
   "52.211.138.4",
   "34.212.152.50",
   "52.215.167.166",
   "52.16.44.217",
   "52.214.6.195",
   "99.80.95.158",
   "44.231.60.247",
   "52.33.57.50",
   "54.188.234.92",
   "44.232.77.64",
   "18.139.37.160",
   "3.0.41.56",
   "13.250.232.14"]
   ]


]


#------ Elements of the array are: --------------------------------------------------
#------ 1: Rule name ----------------------------------------------------------------
#------ 2: Enum: behaviors, criteria, rule ------------------------------------------
#------ 3: Name (identifier of the behavior or criteria). ---------------------------
#------    Leave empty if Enum = rule (in this case the whole rule will be deleted) -
#------------------------------------------------------------------------------------
CLEANUP_SETTINGS = [
    #['Cloudlets Origin Group', 'rule', ''] #Removes cloudlet origins from imported config

]

### IMPORTING PACKAGES AND SETTING CREDENTIALS ###
import json
import sys
if sys.version_info[0] >= 3:
    from urllib.parse import urljoin
else:
    from urlparse import urljoin
from os.path import expanduser #added for importing credentials from .edgerc
from akamai.edgegrid import EdgeGridAuth, EdgeRc
import requests


if IMPORT_SOURCE_IS_STAGING:
    SourcePropertyName = STAGING_PROPERTY_NAME
    TargetPropertyName = PROD_PROPERTY_NAME
else:
    SourcePropertyName = PROD_PROPERTY_NAME
    TargetPropertyName = STAGING_PROPERTY_NAME

###############################################
### Definition of recursive rule processing ###
###############################################
def replace_nested(obj,keyToReplace,search_str,replacement_str,contextKey):
    #print ('Object: ', obj)

    #------ process json object defined as key-value pairs (dict)    
    if type(obj) is dict:
        if keyToReplace in obj.keys():
            #print ('Value: ', obj[keyToReplace])
            if obj[keyToReplace]==search_str:
                obj[keyToReplace] = replacement_str
                #print ('------- obj[keyToReplace]==search_str ------- ')
            if keyToReplace == 'xml': 
                obj[keyToReplace] = obj[keyToReplace].replace(search_str,replacement_str)
            if type(obj[keyToReplace]) is dict:
                #print ('------- type(obj[keyToReplace]) is dict ------- ')
                replace_nested(obj[keyToReplace],keyToReplace,search_str,replacement_str,keyToReplace)
            if type(obj[keyToReplace]) is list:
                #print ('------- type(obj[keyToReplace]) is list ------- ')
                replace_nested(obj[keyToReplace],keyToReplace,search_str,replacement_str,keyToReplace)
        #print ('------- Starting recursive processing ------- ') 
        for everyKey in obj.keys():       
            #print ('Embedded key: ', everyKey) 
            replace_nested(obj[everyKey],keyToReplace,search_str,replacement_str,everyKey)
        #print ('------- End of recursive processing ------- ')

    #------ process etries of a list (array)    
    if type(obj) is list:
        #print ('------- obj is list ------- ')
        for n, everyItem in enumerate(obj):
            if type(everyItem) is str:
                if contextKey==keyToReplace and everyItem==search_str:
                    obj[n] = replacement_str
                    #print('Value ', everyItem, 'of the array with the Key', contextKey, 'is replaced with', replacement_str)
            else:
                replace_nested(everyItem,keyToReplace,search_str,replacement_str,everyItem)


###############################################
### Definition of recursive rule cleanup ######
###############################################
def cleanup_nested_rules(obj,ruleName,enum,enumName):
    #print ('Object: ', obj)
    if type(obj) is dict:
        if 'name' in obj.keys() and obj['name'] == ruleName:
            if enum in obj.keys():
                index = find_element_index(obj[enum], enumName)
                if index != -1:
                    del obj[enum][index]
        else:
        	cleanup_nested_rules(obj['children'],ruleName,enum,enumName)        
    if type(obj) is list:
        index = find_element_index(obj, ruleName)
        if index != -1:
            del obj[index]
###############################################



###############################################
### Returns the index of the list entry #######
###############################################
def find_element_index(listObj, searchValue):
    for counter, listElement in enumerate(listObj):
        if type(listElement) is dict and 'name' in listElement.keys() and listElement['name'] == searchValue:
            return counter
    return -1
###############################################


#################################################
### Reading API credentials from .edgerc file ###
#################################################
home = expanduser('~') #search for .edgerc file in root directory
EDGERC_PATH = '%s/.edgerc' % home 
edgerc = EdgeRc(EDGERC_PATH)
section = 'default' #can replace with PAPI or other section if you prefer
baseurl = 'https://%s' % edgerc.get(section, 'host')

s = requests.Session()
s.auth = EdgeGridAuth.from_edgerc(edgerc, section)
#################################################


#####################################################################
#### LOCATING & RETRIEVING PROPERTY TO BE USED AS CONFIG TEMPLATE ###
#####################################################################
#pinfo_path = '/papi/v1/search/find-by-value' 
#For customer use, use the line above without account SWITCH_KEY
pinfo_path = '/papi/v1/search/find-by-value?accountSwitchKey=' + SWITCH_KEY  #with accountSwitchKey as query parameter

pinfo_headers = {
    'Content-Type': 'application/json',
    'PAPI-Use-Prefixes': 'false'
}
pinfo_data = json.dumps(
{
    'propertyName': SourcePropertyName
})


try:
    #API Call to retrieve version info
    pinfo_res = s.post(urljoin(baseurl, pinfo_path), headers=pinfo_headers, data=pinfo_data)
    pinfo_ = (json.loads(pinfo_res.text))['versions']['items']
except:    #If the first API request fails print error message to check .edgerc file  
    print('ERROR reading .edgerc file')
    print('Please ensure that you have valid API credentials listed in the .edgerc file in the [', section, '] section', sep='')
    print('A valid .edgerc file should be located here:', EDGERC_PATH)
    sys.exit() #escape program if credentials are not succesfully imported
    

# Selects the config version on production / staging
if TRY_TO_RETRIEVE_ACTIVE_VERSION:
    for version in pinfo_:
        if version[VERSION] == 'ACTIVE':
            pinfo = version
            break
else:
    pinfo = pinfo_[0]
    #   pinfo = version # selects latest inactive version if no version is active on selected network
    
print('Retrieving dev property information...')
print('Status code: ', pinfo_res.status_code)
print(pinfo_res.text)
print('Downloading ', SourcePropertyName, ' v', pinfo['propertyVersion'], '...', sep='')


#### GET THE SOURCE PROPERTY RULE TREE ###
# Path:    /papi/v1/properties/{propertyId}/versions/{propertyVersion}/rules{?contractId,groupId,validateRules,validateMode,dryRun}
# Example: /papi/v1/properties/prp_175780/versions/3/rules?contractId=ctr_1–1TJZFW&groupId=grp_15166&validateRules=true&validateMode=fast&dryRun=true

#prule_path = '/papi/v1/properties/{0}/versions/{1}/rules?' \
#            'contractId={2}&groupId={3}'.format(pinfo['propertyId'],
#                pinfo['propertyVersion'], pinfo['contractId'], 
#                pinfo['groupId'])

#For customer use: Use the version above which does not use account SWITCH_KEY
prule_path = '/papi/v1/properties/{0}/versions/{1}/rules?' \
           'contractId={2}&groupId={3}&accountSwitchKey={4}'.format(pinfo['propertyId'],
              pinfo['propertyVersion'], pinfo['contractId'], 
              pinfo['groupId'], SWITCH_KEY)

prule_res = s.get(urljoin(baseurl, prule_path))
    
print('########## Property Rule Tree ##########')
print('Retrieving property rule tree...')
print('Status code: ', prule_res.status_code)
#print(prule_res.text)
prule = json.loads(prule_res.text)

## Save the current version rule tree (json)
sourcePropertyFilename = SourcePropertyName + '.json'
with open(sourcePropertyFilename, 'w') as file:
   file.write(json.dumps(prule, indent=2))
print('JSON saved to the file: ', sourcePropertyFilename)


###################################################################
### UPDATE JSON FILE TO REPLACE ENVIRONMENT-SPECIFIC PARAMETERS ###
###################################################################

#------ Go through the replacement setting list items on-by-one ---------------------
#------ and recursively search through the JSON object ------------------------------
#------ and replace found values for the given keys ---------------------------------
#------------------------------------------------------------------------------------

for item in REPLACEMENT_SETTINGS:
    #print('---Replacement definition:---')
    if IMPORT_SOURCE_IS_STAGING:
        search_str = item[1]
        replace_str = item[2]
    else:
        search_str = item[2]
        replace_str = item[1]
    #print('Key: ',item[0], ', Search: ',search_str, ', Replace: ', replace_str)
    replace_nested(prule,item[0],search_str,replace_str,item[0])
    #print('=============================')

#Here i'll use a simple search/replace for items inside advanced metadata
#prule.replace....


#------ Go through the cleanup setting list items on-by-one -------------------------
#------ and recursively search through the JSON object ------------------------------
#------ and delete found section for the given keys ---------------------------------
#------------------------------------------------------------------------------------

for item in CLEANUP_SETTINGS:
    #print('---Cleanup definition:---')
    enumName =  'with name: ' + item[2] if item[2]!= '' else ''
    #print('Rule: ',item[0], ', To be deleted: ',item[1], enumName)
    cleanup_nested_rules(prule['rules'],item[0],item[1],item[2])    
    #print('=============================')

#Add source property version to comments
prod_comments=prule['comments'] + '; (based on ' + SourcePropertyName + ' v' + str(prule['propertyVersion']) + ')'
prule['comments']=prod_comments
print('New configuration version comments: ')
print(prod_comments)



#########################################
#### LOCATING STAGING PROPERTY TO UPDATE ###
#########################################
##Here we're getting the information for the Prod config that we want to update with the latest dev changes

print('Retrieving destination property info...')
#prodinfo_path = '/papi/v1/search/find-by-value' #Path without accountSwitchKey
prodinfo_path = '/papi/v1/search/find-by-value?accountSwitchKey=' + SWITCH_KEY  #with accountSwitchKey as query parameter
prodinfo_headers = {
   'Content-Type': 'application/json',
   'PAPI-Use-Prefixes': 'false'
}
prodinfo_data = json.dumps(
{
    'propertyName': TargetPropertyName
})


#API Call to retrieve version info
prodinfo_res = s.post(urljoin(baseurl, prodinfo_path), headers=prodinfo_headers, data=prodinfo_data)
prodinfo_ = (json.loads(prodinfo_res.text))['versions']['items']

#Since we are overwriting the configuration with JSON from the dev environment, the 'based on' version is purely for looks and has no functional relevance
#VERSION = 'productionStatus' #Sets 'Based on' version of new config to the version currently on Production  
VERSION = 'stagingStatus' #Sets 'Based on' version of new config to the version currently on Staging  
#VERSION = 'propertyVersion' #Sets 'Based on' version of new config to latest version  


#Selects the prod environment version to pull property information
for version in prodinfo_:
    if version[VERSION] == 'ACTIVE':
        prodinfo = version
        break
    else:
        prodinfo = version # take latest inactive version

print('Status code: ', prodinfo_res.status_code)
print(prodinfo_res.text)

#Save latest property version # as 
prod_version = prodinfo['propertyVersion']
##################################################


#### GET THE DESTINATION PROPERTY RULE TREE ###
#prule_path = '/papi/v1/properties/{0}/versions/{1}/rules?' \
#            'contractId={2}&groupId={3}'.format(prodinfo['propertyId'],
#                prodinfo['propertyVersion'], prodinfo['contractId'], 
#                prodinfo['groupId'])

#For customer use: Use the version above which does not use account SWITCH_KEY
prule_path = '/papi/v1/properties/{0}/versions/{1}/rules?' \
           'contractId={2}&groupId={3}&accountSwitchKey={4}'.format(prodinfo['propertyId'],
              prodinfo['propertyVersion'], prodinfo['contractId'], 
              prodinfo['groupId'], SWITCH_KEY)

prodrule_res = s.get(urljoin(baseurl, prule_path))
    
print('########## Destination Property Rule Tree ##########')
print('Retrieving property destination rule tree...')
print('(', prodinfo['propertyName'], 'version', prodinfo['propertyVersion'],')')
print('Status code: ', prodrule_res.status_code)
print('...')
#print(prule_res.text)
prodrule = json.loads(prodrule_res.text)


########################################################################
### UPDATE JSON FILE TO USE DEFAULT RULE SETTINGS FROM TARGET CONFIG ###
########################################################################
if KEEP_DEFAULT_RULE_SETTINGS == True:
	print("########## Updating working JSON with destination property's default rule ##########")
	print('...')
	#Remove cloudlet origins for working config
	del prule['rules']['behaviors']    
	
	#Retrieve cloudlet origin rule from destination config
	try:
		default_rule = prodrule['rules']['behaviors']

		#Add default rule from destination config to working JSON file
		prule['rules']['behaviors'] = default_rule
		print(' Working JSON successfully updated with destination config default rule')
		print(' ')
	except:
		print(' ERROR: could not update default rule in destination config')
#############################################################################



#############################################################################
### UPDATE JSON FILE TO USE CLOUDLET ORIGINS SETTINGS FROM TARGET CONFIG ###
#############################################################################
if KEEP_CLOUDLET_ORIGINS == True:
	print("########## Updating working JSON with destination property's cloudlet origins ##########")
	print('...')
	#Remove cloudlet origins for working config
	cleanup_nested_rules(prule['rules'],'Cloudlets Origin Group','rule','')    

	#Retrieve cloudlet origin rule from destination config
	try:
		for config_rule in prodrule['rules']['children']:
			if config_rule['name'] == 'Cloudlets Origin Group':
				Cloudlet_Origin_rule = config_rule #Save destination config cloudlet origins to variable
				#print(json.dumps(Cloudlet_Origin_rule))=

		#Add Cloudlet Origins from destination config to working JSON file
		prule['rules']['children'].append(Cloudlet_Origin_rule)
		print(' Working JSON successfully updated with destination config cloudlet origins')
		print(' ')
	except:
		print(' ERROR: cloudlet origins could not be found in destination configuration')
#############################################################################


##########################################################
### UPDATE JSON FILE TO KEEP "HYPE" FROM TARGET CONFIG ###
##########################################################
if KEEP_HYPE_SETTINGS == True:
	print("########## Updating working JSON with destination property's HYPE rules ##########")
	print('...')
	try:
		#Searching for HYPE rule in destination config and save to variable
		for config_rule in prodrule['rules']['children']:
			if config_rule['name'] == 'HYPE':
				print(' HYPE rule located in destination config')
				print(' ...saving to variable...')
				target_hype_json = config_rule #Save destination config cloudlet origins to variable
				#print(json.dumps(target_hype_json))

		#Searching for HYPE rule in working config, and replacing with value saved in target_hype_json
		for index, config_rule in enumerate(prule['rules']['children']):
			if config_rule['name'] == 'HYPE':
				print(' HYPE rule located in working config')
				print(' ...replacing HYPE logic with section from destination config...')
				prule['rules']['children'][index] = target_hype_json
				print(' HYPE succesfully replaced with logic from destination config ')
				print(' ')
		#print(json.dumps(target_hype_json))
				
	except:
		print(' ERROR: Could not retrieve HYPE rules')
##########################################################


print('########## UPDATED Property Rule Tree ##########')
#print(json.dumps(prule, indent=4))

## Save the target version rule tree (json)
targetPropertyFilename = TargetPropertyName + '.json'
with open(targetPropertyFilename, 'w') as file:
    file.write(json.dumps(prule, indent=2))
print('JSON saved to the file: ', targetPropertyFilename)


if UPLOAD_JSON_TO_TARGET_CONFIG:
    ######################################
    ### CREATE NEW STAGING CONFIG VERSION ###
    ######################################

    #pcreate_path = '/papi/v1/properties/{0}/versions?contractId={1}&groupId={2}'.format(
    #                    prodinfo['propertyId'], prodinfo['contractId'], prodinfo['groupId'])                    
                    
    #Replace with version above for customer use (without account SWITCH_KEY)
    pcreate_path = '/papi/v1/properties/{0}/versions?contractId={1}&groupId={2}&accountSwitchKey={3}'.format(
                        prodinfo['propertyId'], prodinfo['contractId'], prodinfo['groupId'],SWITCH_KEY)                    

    pcreate_headers = {
        'Content-Type': 'application/json',
        'PAPI-Use-Prefixes': 'false'
    }
    pcreate_data = json.dumps(
    {
        'createFromVersion': prod_version,
    })

    pcreate_res = s.post(urljoin(baseurl, pcreate_path),
                            headers=pcreate_headers, data=pcreate_data)
    print('########## Property Create ##########')
    print('Creating new version of', prodinfo['propertyName'])
    print('Based on version:', prodinfo['propertyVersion'])
    print('...')
    print('Status code: ', pcreate_res.status_code)
    print(pcreate_res.headers)
    print(pcreate_res.text)
    pcreate = json.loads(pcreate_res.text)
    # extract version here
    if pcreate:
        pcreate_version = int(pcreate['versionLink']
            .rsplit('/', 1)[-1]
            .rsplit('?', 1)[0])
    ######################################




    ######################################
    ### UPLOAD JSON RULE TREE AND SAVE ###        
    ######################################

    #pupdate = '/papi/v1/properties/{0}/versions/{1}/rules?' \
    #            'contractId={2}&groupId={3}'.format(prodinfo['propertyId'],
    #                pcreate_version, prodinfo['contractId'], 
    #                prodinfo['groupId'])

    #Use version above if you are not using an account SWITCH_KEY
    pupdate = '/papi/v1/properties/{0}/versions/{1}/rules?' \
                'contractId={2}&groupId={3}&accountSwitchKey={4}'.format(prodinfo['propertyId'],
                    pcreate_version, prodinfo['contractId'], 
                    prodinfo['groupId'],SWITCH_KEY)
                                
    pupdate_header = {
        # 'Content-Type': 'application/vnd.akamai.papirules.v2017-06-19+json',
        'Content-Type': 'application/json',
        # 'If-Match': ''{0}''.format(pversion_etag),
        'PAPI-Use-Prefixes': 'false'
    }

    # API Call to upload working JSON config to production configuration
    pupdate_res = s.put(urljoin(baseurl, pupdate), 
                            headers=pupdate_header, data=json.dumps(prule))
    print('########## Property Update ##########')
    print('Status code: ', pupdate_res.status_code)
    #print(pupdate_res.headers)
    #print(pupdate_res.text)

    if pupdate_res.status_code == 200:
        print('*** ',prodinfo['propertyName'], ' v', pcreate_version, ' created succesfully! ***', sep='')
    ######################################


###########################################
### PUSH NEW CONFIG VERSION TO DEV? ###      
# Here you could add the API call to activate this version on Staging if you wish
###########################################