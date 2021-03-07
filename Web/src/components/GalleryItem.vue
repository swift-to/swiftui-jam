<template>
  <div class="gallery">
     <div v-if="submission != null" class="selected-submission">
      <h3 class="nav-item" @click="showGallery()">&lt; Back to Gallery</h3>
      <div class="text-info">
        <h4 class="submission-name">{{submission.name}}</h4>
        <h5 class="submission-team">By {{submission.team.name}}</h5>
        <p class="submission-team-members">
          <strong>Team Members:</strong>&nbsp;
          <span 
            class="team-member"
            v-for="member in submission.team.members"
            v-bind:key="member.id">{{member.name}}</span>
        </p>
        <p class="submission-description">{{submission.description}}</p>
        <p class="submission-tags"
          v-if="submission.tags != null && submission.tags.length > 0">
            <strong>Tags:</strong> {{submission.tags}}
        </p>
        <p class="submission-credits"
          v-if="submission.credits != null && submission.credits.length > 0">
            <strong>Credits:</strong> {{submission.credits}}
        </p>
        <a 
          target = "_blank"
          v-if="submission.repoUrl != nil" 
          v-bind:href="submission.repoUrl">🌎 Visit Git Repo</a>
        <a 
          target = "_blank"
          v-if="submission.repoUrl != nil" 
          v-bind:href="submission.latestRepoUrl">🌎 Visit Latest Git Repo</a>
        <a 
          target = "_blank"
          v-if="submission.blogUrl != nil" 
          v-bind:href="submission.blogUrl">🌎 Visit Blog</a>
        <a 
          target = "_blank"
          v-if="submission.downloadUrl != nil" 
          v-bind:href="submission.downloadUrl">🌎 Download App</a>
      </div>
      <div class="submission-images">
        <img 
          class="submission-image" 
          v-for="image in submission.images" 
          v-bind:key="image.id"
          v-bind:src="image.url" /> 
      </div>
      
     </div>
  </div>
</template>

<script>
export default {
  name: 'GalleryItem',
  props: ['routingParameters'],
  data: () => {
    return { 
      submission: null
    }
  },
  created: function() {
    if(this.routingParameters != null && this.routingParameters.length > 0) {
      this.loadSubmission(this.routingParameters[0])
    }
  },
  computed: {},
  methods: {
    loadSubmission: function(submissionId) {
      var xhr = new XMLHttpRequest();
      xhr.onload = () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          console.log(xhr.response)
          this.submission = JSON.parse(xhr.responseText)
        } else {
          alert(xhr.responseText)
        }
      }
      xhr.open('GET', process.env.VUE_APP_BASE_API_URL + `/api/submissions/${submissionId}`)
      xhr.send()
    },
    showGallery: function() {
      window.location.hash = "#gallery"
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
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
  font-size: 24px;
  margin: 0;
  color: cornflowerblue;
}

h5.submission-team {
  font-size: 20px;
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

span.team-member {
  display: inline-block;
  font-weight: bold;
  margin-right: 4px;
}
span.team-member::after {
  content: ",";
}
span.team-member:last-child::after {
  content: "";
}

</style>
