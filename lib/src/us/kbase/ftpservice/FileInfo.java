
package us.kbase.ftpservice;

import java.util.HashMap;
import java.util.Map;
import javax.annotation.Generated;
import com.fasterxml.jackson.annotation.JsonAnyGetter;
import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;


/**
 * <p>Original spec-file type: fileInfo</p>
 * 
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "file_link",
    "file_name",
    "file_size",
    "file_type",
    "isFolder",
    "date"
})
public class FileInfo {

    @JsonProperty("file_link")
    private String fileLink;
    @JsonProperty("file_name")
    private String fileName;
    @JsonProperty("file_size")
    private Double fileSize;
    @JsonProperty("file_type")
    private String fileType;
    @JsonProperty("isFolder")
    private String isFolder;
    @JsonProperty("date")
    private String date;
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("file_link")
    public String getFileLink() {
        return fileLink;
    }

    @JsonProperty("file_link")
    public void setFileLink(String fileLink) {
        this.fileLink = fileLink;
    }

    public FileInfo withFileLink(String fileLink) {
        this.fileLink = fileLink;
        return this;
    }

    @JsonProperty("file_name")
    public String getFileName() {
        return fileName;
    }

    @JsonProperty("file_name")
    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public FileInfo withFileName(String fileName) {
        this.fileName = fileName;
        return this;
    }

    @JsonProperty("file_size")
    public Double getFileSize() {
        return fileSize;
    }

    @JsonProperty("file_size")
    public void setFileSize(Double fileSize) {
        this.fileSize = fileSize;
    }

    public FileInfo withFileSize(Double fileSize) {
        this.fileSize = fileSize;
        return this;
    }

    @JsonProperty("file_type")
    public String getFileType() {
        return fileType;
    }

    @JsonProperty("file_type")
    public void setFileType(String fileType) {
        this.fileType = fileType;
    }

    public FileInfo withFileType(String fileType) {
        this.fileType = fileType;
        return this;
    }

    @JsonProperty("isFolder")
    public String getIsFolder() {
        return isFolder;
    }

    @JsonProperty("isFolder")
    public void setIsFolder(String isFolder) {
        this.isFolder = isFolder;
    }

    public FileInfo withIsFolder(String isFolder) {
        this.isFolder = isFolder;
        return this;
    }

    @JsonProperty("date")
    public String getDate() {
        return date;
    }

    @JsonProperty("date")
    public void setDate(String date) {
        this.date = date;
    }

    public FileInfo withDate(String date) {
        this.date = date;
        return this;
    }

    @JsonAnyGetter
    public Map<String, Object> getAdditionalProperties() {
        return this.additionalProperties;
    }

    @JsonAnySetter
    public void setAdditionalProperties(String name, Object value) {
        this.additionalProperties.put(name, value);
    }

    @Override
    public String toString() {
        return ((((((((((((((("FileInfo"+" [fileLink=")+ fileLink)+", fileName=")+ fileName)+", fileSize=")+ fileSize)+", fileType=")+ fileType)+", isFolder=")+ isFolder)+", date=")+ date)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
