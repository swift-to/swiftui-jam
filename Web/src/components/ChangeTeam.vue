<template>
  <div class="change-team">
    <label for="teamId">Change Team</label>
    <select name="teamId" id="teamId" v-model="teamId">
      <option v-for="team in teams" v-bind:key="team.id" :value="team.id">{{team.name}}</option>
    </select>
    <button class="nav-item" type="submit" @click="updateTeam()">Submit</button>
  </div>
</template>

<script>
export default {
  name: 'ChangeTeam',
  props: ['accessToken', 'state', 'user'],
  data: () => {
    return { 
      teams: [],
      teamId: null
    }
  },
  created: function() {
    if (this.user.team) {
      this.teamId = this.user.team.id
    }
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
          this.$emit('editComplete')
        } else {
          alert(xhr.responseText)
        }
      }
      xhr.open('POST', process.env.VUE_APP_BASE_API_URL + '/api/me/team')
      xhr.setRequestHeader("Content-Type", "application/json")
      xhr.setRequestHeader("Authorization", `Bearer ${this.accessToken}`)
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
