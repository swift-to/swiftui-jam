
export default class ImageUploadFlowManager {

  constructor(accessToken, submissionId, file, fileInfo) {
    this.accessToken = accessToken
    this.submissionId = submissionId
    this.file = file
    this.fileInfo = fileInfo
  }

  startFlow(completion) {
    this.requestImageUpload(completion)
  }

  requestImageUpload (completion) {
    var xhr = new XMLHttpRequest();
     xhr.onload = () => {
       if (xhr.status >= 200 && xhr.status < 300) {
         console.log(xhr.response)
         let uploadInfo = JSON.parse(xhr.responseText)
         this.uploadImage(uploadInfo, completion)
       } 
       else if(xhr.status == 401) {
         completion(401)
       }
       else {
         alert(xhr.responseText)
         completion(400)
       }
     }

     xhr.open('POST', `${process.env.VUE_APP_BASE_API_URL}/api/submissions/${this.submissionId}/images/upload`)
     xhr.setRequestHeader("Content-Type", "application/json")
     xhr.setRequestHeader("Authorization", `Bearer ${this.accessToken}`)
     xhr.send(JSON.stringify({info: this.fileInfo})) 
   }

   uploadImage (uploadLocationInfo, completion) {
     var xhr = new XMLHttpRequest();
     xhr.onload = () => {
       if (xhr.status >= 200 && xhr.status < 300) {
         console.log("upload complete", xhr.response)
         this.confirmUpload(uploadLocationInfo, completion)
       }
       else {
         alert(xhr.responseText)
         completion(400)
       }
     }

     xhr.open('PUT', uploadLocationInfo.uploadUrl)
     // xhr.setRequestHeader("Content-MD5", this.fileInfo.md5Hash)
     xhr.send(this.file) 
   }

   confirmUpload (uploadLocationInfo, completion) {
     var xhr = new XMLHttpRequest();
     xhr.onload = () => {
       if (xhr.status >= 200 && xhr.status < 300) {
         console.log("confirmation complete", xhr.response)
         completion(null)
       } 
       else if(xhr.status == 401) {
        completion(401)
       }
       else {
         alert(xhr.responseText)
         completion(400)
       }
     }

     xhr.open('PUT', `${process.env.VUE_APP_BASE_API_URL}/api/submissions/${this.submissionId}/images/${uploadLocationInfo.id}/confirm`)
     xhr.setRequestHeader("Content-Type", "application/json")
     xhr.setRequestHeader("Authorization", `Bearer ${this.accessToken}`)
     xhr.send()
   }
}