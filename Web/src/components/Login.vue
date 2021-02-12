<template>
  <div class="login">

    <p>Currently this system functions by email login
    <br />Submit your registered email address and we will mail you a link with access for 24 hours.</p>
      
    <label for="name">Email</label>
    <input type="text" name="name" id="name" v-model="email">

    <button class="nav-item" type="submit" @click="login()">Submit</button>
  </div>
</template>

<script>
export default {
  name: 'Login',
  data: () => {
    return { 
      email: ""
    }
  },
  methods: {
    login: function() {
      var xhr = new XMLHttpRequest();
      xhr.onload = () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          console.log(xhr.response)
          alert("Check your email for an access link from hello@swiftuijam.com")
        } else {
          alert(xhr.responseText)
        }
      }

      xhr.open('POST', `${process.env.VUE_APP_BASE_API_URL}/api/login/email`)
      xhr.setRequestHeader("Content-Type", "application/json")
      xhr.send(JSON.stringify({
        email: this.email
      }))
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

</style>
