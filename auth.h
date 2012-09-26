// SVN: $Revision$
int auth_eb_user(int fd, int to, users *user_map, std::string & password, long long unsigned int *challenge, bool is_proxy_auth, bool *is_server_in, std::string & type, random_source_t rs);
int auth_eb(int fd, int to, users *user_map, std::string & password, long long unsigned int *challenge, bool *is_server_in, std::string & type, random_source_t rs);
int auth_client_server(int fd, int to, std::string & username, std::string & password, long long unsigned int *challenge, bool is_server, std::string type);
int auth_client_server_user(int fd, int to, std::string & username, std::string & password, long long unsigned int *challenge, bool is_server, std::string type);
bool get_auth_from_file(char *filename, std::string & username, std::string & password);
