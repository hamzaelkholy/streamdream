import { Controller } from "stimulus";
import ProgressBar from "progressbar.js";

export default class extends Controller {
  static targets = ["cards", "alreadyConnected"];

  countMovies() {
    let selected = document.querySelectorAll(".hide-checkbox:checked");
    let already_selected = this.alreadyConnectedTarget.value.split(" ").length;
    // console.log(selected.length + already_selected);
    this.accuracyBar.animate((selected.length + already_selected) / 9);

    // if (this.accuracyBar.value() >= 0.888889) {
    //   this.accuracyBar.setText("Done");
    // }
  }

  connect() {
    // console.log(this.cardsTarget);
    const movieArray = JSON.parse(this.element.dataset.moviesUrl);

    let already_selected = this.alreadyConnectedTarget.value;

    this.accuracyBar = new ProgressBar.Line("#accuracy-meter", {
      strokeWidth: 2,
      easing: "easeInOut",

      trailColor: "#fbf9f9",

      from: { color: "#bf1336" },
      to: { color: "#6EE688" },
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

      // Add button to card
      div.insertAdjacentHTML(
        "beforeend",
        "<i class='info-btn fas fa-info-circle' data-toggle='modal' data-target='#exampleModal'></i>"
      );
    });

    // Get info button
    const infoBtn = document.querySelectorAll(".info-btn");

    // For each button, get the id of the movie
    infoBtn.forEach((btn) => {
      btn.addEventListener("click", (e) => {
        const movieId = e.target.parentElement.childNodes[0].value;
        e.target.dataset.target = `#exampleModal-${movieId}`;
        console.log(e.target.dataset.target);
      });
    });
  }
}
