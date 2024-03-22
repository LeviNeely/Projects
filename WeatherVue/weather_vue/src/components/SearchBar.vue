<template>
  <div>
    <input type="text" v-model="searchQuery" placeholder="Enter an address or city">
    <button @click="search">Search</button>
    <div v-if="weatherData">
      <h2>{{ weatherData.name }}</h2>
      <img :src="weatherData.icon" alt="Weather Icon">
      <p>{{ weatherData.temperature }}°F</p>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      searchQuery: '',
      weatherData: null, // Initialize weatherData to hold weather information
    };
  },
  methods: {
    async search() {
      const url = `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(this.searchQuery)}&format=jsonv2`;
      try {
        const response = await fetch(url);
        const data = await response.json();
        if (data.length > 0) {
          const lat = data[0].lat;
          const lon = data[0].lon;
          const url2 = `https://api.weather.gov/points/${lat},${lon}`;
          try {
            const response2 = await fetch(url2);
            const data2 = await response2.json();
            const url3 = data2.properties.forecast;
            try {
              const response3 = await fetch(url3);
              const data3 = await response3.json();
              if (data3 && data3.properties && data3.properties.periods && data3.properties.periods.length > 0) {
                // Assume we want to display the first period's weather data
                const weatherInfo = data3.properties.periods[0];
                this.weatherData = {
                  name: weatherInfo.name,
                  temperature: weatherInfo.temperature,
                  icon: weatherInfo.icon
                };
              }
            } catch (error) {
              console.error('Error fetching weather data:', error);
            }
          } catch (error) {
            console.error('Error fetching weather data:', error);
          }
        }
      } catch (error) {
        console.error('Error fetching geocode:', error);
      }
    },
  },
};
</script>
