// Used for saving to the Keychain.
#define PASSWORD @"HPCSPassword"

// Used for saving the user's name to NSUserDefaults.
#define USERNAME @"HPCSUsername"

// Used for saving the tenantId to NSUserDefaults
#define TENANT_ID  @"HPCSTenantId"

// Used to specify the application used in accessing the Keychain.
#define APP_NAME [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]

// Used for saving to the Keychain.
#define TOKEN @"HPCSToken"

#define SERVICE_CATALOG @"HPCSServiceCatalog"
