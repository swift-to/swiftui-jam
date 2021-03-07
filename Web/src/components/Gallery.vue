<template>
  <div class="gallery">
     <h3>Gallery</h3>
     <div v-if="selectedSubmission == null" class="gallery-container">
      <h4 v-if="submissions.length == 0">Loading Submissions...</h4>
      <div class="gallery-item"
       v-for="submission in submissions" 
       v-bind:key="submission.id"
       @click="selectSubmission(submission)">
        <img v-if="getSubmissionCoverImage(submission) != null" class="preview-image" v-bind:src="getSubmissionCoverImage(submission)" />
        <div class="text-info">
          <h4 class="submission-name">{{submission.name}}</h4>
          <h5 class="submission-team">By {{submission.team.name}}</h5>
        </div>
      </div>
     </div>
  </div>
</template>

<script>
export default {
  name: 'Gallery',
  data: () => {
    return { 
      submissions: []
    }
  },
  created: function() {
    this.loadSubmissions()
  },
  computed: {},
  methods: {
    getSubmissionCoverImage: function (submission) {
      if (submission.images.length == 0) { 
        return null 
      } else if (submission.coverImageId != null) {
        let img = submission.images.find((img) => { return img.id == submission.coverImageId })
        if (img != null) {
          return img.url
        } else {
          return submission.images[0].url  
        }
      } else {
        return submission.images[0].url 
      }
    },
    loadSubmissions: function() {
      var xhr = new XMLHttpRequest();
      xhr.onload = () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          console.log(xhr.response)
          this.submissions = JSON.parse(xhr.responseText)
        } else {
          alert(xhr.responseText)
        }
      }
      xhr.open('GET', process.env.VUE_APP_BASE_API_URL + '/api/submissions')
      xhr.send()
    },
    selectSubmission: function(submission) {
      window.location.hash = `#gallery-item/${submission.id}`
    }
  }
}
</script>

<style scoped>

.gallery-container, .submission-images {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  justify-content: center;
}

.gallery-item {
  width: 250px;
  margin: 10px 10px 40px 10px;
  cursor: pointer;
}

.gallery-container .gallery-item:hover .text-info {
  background-color: #efefef;
}

.text-info {
  padding: 8px;
  margin-top: 10px;
  border-radius: 4px;
}

.text-info a {
  display: block;
  font-weight: bold;
  font-size: 20px;
}

h4.submission-name {
  font-size: 18px;
  margin: 0;
  color: cornflowerblue;
}

h5.submission-team {
  font-size: 16px;
  margin: 0;
  color: #888;
}

.preview-image {
  width: 250px;
  height: 250px;
  object-fit: cover;
}

.submission-image {
  width: 250px;
  object-fit: contain;
  margin: 0 10px;
}

</style>
