<template>
  <div class="submit">
      <form>
        <h3>New Submission</h3>

        <p>Let's start by getting this submission's name and description.</p>

         <label for="name">Name*</label>
         <input type="text" name="name" id="name" v-model="submission.name">

         <label for="description">Description*</label>
         <textarea name="description" id="description" v-model="submission.description"></textarea>

      </form>
      <br />
      <button class="nav-item" type="submit" @click="submit()">Create New Submission</button>
  </div>
</template>

<script>

export default {
  name: 'Submit',
  props: ['accessToken'],
  data: () => {
    return { 
      submission: {
        name: "",
        description: ""
      }
    }
  },
  created: function() {
    console.log('my access token', this.accessToken)
  },
  computed: {},
  methods: {
    submit: function() {
      var xhr = new XMLHttpRequest();
      xhr.onload = () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          console.log(xhr.response)
          this.$emit('newSubmissionCreated')
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
        description: this.submission.description
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
