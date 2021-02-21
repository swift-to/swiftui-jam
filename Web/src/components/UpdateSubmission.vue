<template>
  <div class="submit">
    <div class="form-container">
      <form>

         <label for="name">Name*</label>
         <input type="text" name="name" id="name" v-model="submissionForm.name">

         <label for="description">Description*</label>
         <textarea name="description" id="description" v-model="submissionForm.description"></textarea>

         <label for="repoUrl">Git Repo Url</label>
         <input type="text" name="repoUrl" id="repoUrl" v-model="submissionForm.repoUrl">

         <label for="downloadUrl">Download Url</label>
         <input type="text" name="downloadUrl" id="downloadUrl" v-model="submissionForm.downloadUrl">

         <label for="state">Blog Url</label>
         <input type="text" name="blogUrl" id="blogUrl" v-model="submissionForm.blogUrl">

         <label for="tags">Tags - Comma Separated (e.g. macos,ios,game,funny etc..)</label>
         <input type="text" name="tags" id="tags" v-model="submissionForm.tags">

         <label for="credits">Credits - Did you work with any designers not listed on your team? <br />Other resources you want to thank?</label>
         <textarea name="credits" id="credits" v-model="submissionForm.credits"></textarea>

         <label for="credits">Upload New Image</label>
         <input type="file"
           id="imageUploadInput" 
           name="image"
           accept="image/png, image/jpeg, image/gif" 
           v-if="isUploadingImage == false"
           @change="imageSelectionChanged">
          <p v-if="isUploadingImage == true">Uploading image....</p>

      </form>
      <br />
    </div>
    <div class="images">
        <h3>Uploaded Images</h3>
        <div class="image-container" v-for="image in submission.images" v-bind:key="image.id">
          <img class="preview-image" v-bind:src="image.url" />
          <button class="delete" @click="deleteImage(image.id)">❌</button>
        </div>
    </div>
    <button class="nav-item save" type="submit" @click="submit()">Save</button>
  </div>
</template>

<script>

import CryptoJS from 'crypto-js'
import ImageUploadFlowManager from '../ImageUploadFlowManager'

export default {
  name: 'UpdateSubmission',
  props: ['accessToken', 'submission'],
  data: () => {
    return { 
      isUploadingImage: false,
      submissionForm: {
        name: "",
        description: "",
        repoUrl: "",
        downloadUrl: "",
        blogUrl: "",
        tags: "",
        credits: ""
      }
    }
  },
  created: function() {
    console.log('my access token', this.accessToken)
    this.submissionForm = {
        name: this.submission.name,
        description: this.submission.description,
        repoUrl: this.submission.repoUrl,
        downloadUrl: this.submission.downloadUrl,
        blogUrl: this.submission.blogUrl,
        tags: this.submission.tags,
        credits: this.submission.credits
    }
  },
  computed: {},
  methods: {
    imageSelectionChanged: function (event) {
        console.log("image selection change", event.target.files)
        this.isUploadingImage = true

        if (event.target.files.length == 0) { 
          return 
        }

        var file = event.target.files[0];
        var reader = new FileReader();

        reader.onload = (event) => {
          var binary = event.target.result;
          var md5 = CryptoJS.MD5(binary).toString();
          const info = {
            md5Hash: md5,
            bytes: file.size,
            mimeType: file.type
          }

          let imageFlowManager = new ImageUploadFlowManager(this.accessToken, this.submission.id, file, info)
            imageFlowManager.startFlow((error) => {
                if (error == 401) {
                  this.$emit('unauthorizedResponse') 
                } else {
                  this.$emit('submissionNeedsReload')
                }
                this.isUploadingImage = false
                document.getElementById('imageUploadInput').value = ''
            })
        };

        reader.readAsBinaryString(file);
    },
    submit: function() {
      var xhr = new XMLHttpRequest();
      xhr.onload = () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          console.log(xhr.response)
          this.$emit('editComplete')
        } 
        else if(xhr.status == 401) {
          this.$emit('unauthorizedResponse')
        }
        else {
          alert(xhr.responseText)
        }
      }

      xhr.open('PATCH', `${process.env.VUE_APP_BASE_API_URL}/api/submissions/${this.submission.id}`)
      xhr.setRequestHeader("Content-Type", "application/json")
      xhr.setRequestHeader("Authorization", `Bearer ${this.accessToken}`)
      xhr.send(JSON.stringify({
        name: this.submissionForm.name,
        description: this.submissionForm.description,
        repoUrl: this.submissionForm.repoUrl,
        downloadUrl: this.submissionForm.downloadUrl,
        blogUrl: this.submissionForm.blogUrl,
        tags: this.submissionForm.tags,
        credits: this.submissionForm.credits
      }))
    },
    deleteImage: function(imageId) {
      var xhr = new XMLHttpRequest();
      xhr.onload = () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          console.log(xhr.response)
          this.$emit('submissionNeedsReload')
        } 
        else if(xhr.status == 401) {
          this.$emit('unauthorizedResponse')
        }
        else {
          alert(xhr.responseText)
        }
      }

      xhr.open('DELETE', `${process.env.VUE_APP_BASE_API_URL}/api/submissions/${this.submission.id}/images/${imageId}`)
      xhr.setRequestHeader("Content-Type", "application/json")
      xhr.setRequestHeader("Authorization", `Bearer ${this.accessToken}`)
      xhr.send()
    },
    onUnauthedResponse: function() {
      this.$emit('unauthorizedResponse')
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

.actions, .my-info {
  float: left;
  padding: 0 20pt;
}

.actions

dl {
  margin-left: 20pt;
}

dt {
  font-weight: bold;
}

div.form-container, div.images {
  margin: 10px;
}

.image-container {
  position: relative;
  float: left;
}

.preview-image {
    border: 1px solid #ddd;
    border-radius: 4px; 
    padding: 5px;
    margin-right: 20px; 
    width: 150px;
}

button.delete {
  position: absolute;
  right: 0;
  top: 0;
}

button.save {
  clear: both;
}

</style>
