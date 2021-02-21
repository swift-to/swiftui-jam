<template>
  <div class="edit-team-name">
    <label for="teamName">Update Team Name</label>
    <input name="teamName" id="teamName" v-model="teamName">
    <button class="nav-item" type="submit" @click="updateTeamName()">Submit</button>
  </div>
</template>

<script>
export default {
  name: 'EditTeamName',
  props: ['accessToken', 'user'],
  data: () => {
    return { 
      teamName: ""
    }
  },
  created: function() {
    this.teamName = this.user.team.name
  },
  methods: {
    updateTeamName: function() {
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
      xhr.open('PATCH', process.env.VUE_APP_BASE_API_URL + '/api/teams/:id')
      xhr.setRequestHeader("Content-Type", "application/json")
      xhr.setRequestHeader("Authorization", `Bearer ${this.accessToken}`)
      xhr.send(JSON.stringify({
        name: this.teamName
      }))
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

</style>
