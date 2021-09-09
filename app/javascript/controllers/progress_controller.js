import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["output"];

  getRandomColor() {
    let color = `hsl(220, ${Math.random() * 70 + 40}%,
    ${Math.random() * 70 + 40}%)`;
    return color;
  }

  connect() {
    // Get the params from ruby
    const params = JSON.parse(this.element.dataset.params);

    // Format genres
    const genres = params.statistics.genres;
    const formatted_genres = [];
    genres.forEach((element) => {
      formatted_genres.push(element.replace(/\s/g, ""));
    });

    // Get count of genres
    const totalGenres = genres.length;

    // Create object to hold count of genres
    const countGenres = {};
    for (const num of formatted_genres) {
      countGenres[num] = countGenres[num] ? countGenres[num] + 1 : 1;
    }

    // Get progressbar container
    const progressContainer = document.querySelector(".progress");
    for (const key in countGenres) {
      // Get percentage of total
      const percent = totalGenres / countGenres[key];

      const progressBar = `<div class="progress-bar" role="progressbar" style="width: ${percent}%; background-color: ${this.getRandomColor()}" aria-valuemin="0" aria-valuemax="100"><p class="progress-label">${key}</p> ${percent}%</div>`;
      // Insert progress bar
      progressContainer.insertAdjacentHTML("beforeend", progressBar);
      // console.log(`${key}: ${countGenres[key]}`);
    }
  }
}
