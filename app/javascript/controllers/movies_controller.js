import { Controller } from "stimulus";
import ProgressBar from "progressbar.js";

export default class extends Controller {
  static targets = ["cards", "alreadyConnected"];

  countMovies() {
    let selected = document.querySelectorAll(".hide-checkbox:checked");
    let already_selected = this.alreadyConnectedTarget.value.split(" ").length;
    console.log(selected.length + already_selected);
    this.accuracyBar.animate((selected.length + already_selected) / 13);
  }

  connect() {
    // console.log(this.cardsTarget);
    const movieArray = JSON.parse(this.element.dataset.moviesUrl);

    let already_selected = this.alreadyConnectedTarget.value;

    this.accuracyBar = new ProgressBar.Line("#accuracy-meter", {
      strokeWidth: 2,
      easing: "easeInOut",

      trailColor: "#fbf9f9",

      from: { color: "#f7797d" },
      to: { color: "#C6FFDD" },
      step: function (state, line) {
        line.path.setAttribute("stroke", state.color);
      },
    });

    this.accuracyBar.animate(already_selected.split(" ").length / 12);

    this.element.querySelectorAll(".image-card").forEach((div) => {
      let id = +div.querySelector("input").value;
      // Get id of movie
      let movieHash = movieArray.find((movie) => {
        return movie.id == id;
      });
      // put poster url as background
      div.style.backgroundImage = `url(${movieHash.url})`;
      div.style.backgroundSize = "cover";

      div.insertAdjacentHTML();
    });
  }
}
