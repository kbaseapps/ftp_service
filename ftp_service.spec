/*
A KBase module: ftp_service
This module serve as a service that lists files and file info in users private ftp space
*/

module ftp_service {

    typedef structure {
        string token;
        string type;
        string username;
    } listFilesInputParams;

    typedef structure {
        string file_link;
        string file_name;
        float file_size;
        string file_type;
        string isFolder;
        string date;
    }fileInfo;

    typedef structure {
        list <fileInfo> files;
        string username;
    } listFilesOutputPparams;

    funcdef list_files(listFilesInputParams params) returns (listFilesOutputPparams output) authentication required;
};
