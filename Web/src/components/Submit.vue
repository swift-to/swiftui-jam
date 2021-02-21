<template>
  <div class="submit">
      <form>

         <label for="name">Name*</label>
         <input type="text" name="name" id="name" v-model="submission.name">

         <label for="description">Description*</label>
         <input type="text" name="description" id="description" v-model="submission.description">

         <label for="repoUrl">Git Repo Url</label>
         <input type="text" name="repoUrl" id="repoUrl" v-model="submission.repoUrl">

         <label for="downloadUrl">Download Url</label>
         <input type="text" name="downloadUrl" id="downloadUrl" v-model="submission.downloadUrl">

         <label for="state">Blog Url</label>
         <input type="text" name="blogUrl" id="blogUrl" v-model="submission.blogUrl">

         <label for="tags">Tags</label>
         <input type="text" name="tags" id="tags" v-model="submission.tags">

         <label for="credits">Credits</label>
         <input type="text" name="credits" id="credits" v-model="submission.credits">

         <input type="file"
           id="image" 
           name="image"
           accept="image/png, image/jpeg, image/gif" @change="imageSelectionChanged">

      </form>
      <button class="nav-item" type="submit" @click="submit()">Submit</button>
  </div>
</template>

<script>

import CryptoJS from 'crypto-js'
import ImageUploadFlowManager from '../ImageUploadFlowManager'

export default {
  name: 'Submit',
  props: ['accessToken'],
  data: () => {
    return { 
      submission: {
        name: "",
        description: "",
        repoUrl: "",
        downloadUrl: "",
        blogUrl: "",
        tags: "",
        credits: ""
      },
      fileInfo: null,
      file: null
    }
  },
  created: function() {
    console.log('my access token', this.accessToken)
  },
  computed: {},
  methods: {
    imageSelectionChanged: function (event) {
        console.log("image selection change", event.target.files)

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

          this.file = file
          this.fileInfo = info
        };

        reader.readAsBinaryString(file);
    },
    submit: function() {
      var xhr = new XMLHttpRequest();
      xhr.onload = () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          console.log(xhr.response)
          let submission = JSON.parse(xhr.responseText)
          if (this.file != null && this.fileInfo != null) {
            let imageFlowManager = new ImageUploadFlowManager(this.accessToken, submission.id, this.file, this.fileInfo)
            imageFlowManager.startFlow((error) => {
                if (error == 401) {
                  this.$emit('unauthorizedResponse') 
                } else {
                  this.$emit('editComplete') 
                }
            })
          } else {
            this.$emit('editComplete')
          }
        } 
        else if(xhr.status == 401) {
          this.$emit('unauthorizedResponse')
        }
        else {
          alert(xhr.responseText)
        }
      }

      xhr.open('POST', `${process.env.VUE_APP_BASE_API_URL}/api/submissions`)
      xhr.setRequestHeader("Content-Type", "application/json")
      xhr.setRequestHeader("Authorization", `Bearer ${this.accessToken}`)
      xhr.send(JSON.stringify({
        name: this.submission.name,
        description: this.submission.description,
        repoUrl: this.submission.repoUrl,
        downloadUrl: this.submission.downloadUrl,
        blogUrl: this.submission.blogUrl,
        tags: this.submission.tags,
        credits: this.submission.credits
      }))
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

</style>
