<template>
  <div class="edit-team-name">
    <label for="teamId">Update Team</label>
    <select name="teamId" id="teamId" v-model="teamId">
      <option v-for="team in teams" v-bind:key="team.id" :value="team.id">{{team.name}}</option>
    </select>
    <button class="nav-item" type="submit" @click="updateTeam()">Submit</button>
  </div>
</template>

<script>
export default {
  name: 'Me',
  props: ['accessToken', 'state', 'user'],
  data: () => {
    return { 
      teams: [],
      teamId: null
    }
  },
  created: function() {
    this.loadTeams()
  },
  methods: {
    loadTeams: function() {
      var xhr = new XMLHttpRequest();
      xhr.onload = () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          console.log(xhr.response)
          this.teams = JSON.parse(xhr.responseText)
        } else {
          alert(xhr.responseText)
        }
      }
      xhr.open('GET', process.env.VUE_APP_BASE_API_URL + '/api/teams')
      xhr.send()
    },
    updateTeam: function() {
      var xhr = new XMLHttpRequest();
      xhr.onload = () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          console.log(xhr.response)
          this.state = 'home'
        } else {
          alert(xhr.responseText)
        }
      }
      xhr.open('POST', process.env.VUE_APP_BASE_API_URL + '/api/me/team')
      xhr.setRequestHeader("Content-Type", "application/json")
      xhr.send(JSON.stringify({
        teamId: this.teamId
      }))
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

</style>
