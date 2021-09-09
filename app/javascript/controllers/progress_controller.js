import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["output"];

  getRandomColor() {
    let letters = "0123456789ABCDEF";
    let color = "#";
    for (let i = 0; i < 6; i++) {
      color += letters[Math.floor(Math.random() * 16)];
    }
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
    // Get genre container
    const genresContainer = document.querySelector(".progress");
    this.createProgressBar(formatted_genres, genresContainer);

    console.log("Directors");

    // const directors = params.statistics.directors;
    // // Get director container
    // const directorsContainer = document.querySelector(".directors");
    // this.createProgressBar(directors, directorsContainer);
  }

  createProgressBar(statistic, container) {
    // Get count of statistic
    const total = statistic.length;

    // Create object to hold count of statistic
    const count = {};
    for (const num of statistic) {
      count[num] = count[num] ? count[num] + 1 : 1;
    }

    for (const key in count) {
      // Get percentage of total
      const percent = total / count[key];
      console.log(percent);

      const progressBar = `<div class="progress-bar" role="progressbar" style="width: ${percent}%; background-color: ${this.getRandomColor()}" aria-valuemin="0" aria-valuemax="100"><p class="progress-label">${key} ${Math.round(
        percent
      )}%</p></div>`;
      // Insert progress bar
      container.insertAdjacentHTML("beforeend", progressBar);
      // console.log(`${key}: ${countGenres[key]}`);
    }
  }
}
