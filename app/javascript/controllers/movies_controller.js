import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["cards"];

  connect() {
    // console.log(this.cardsTarget);

    const movieArray = JSON.parse(this.element.dataset.moviesUrl);

    this.element.querySelectorAll(".image-card").forEach((div) => {
      let id = +div.querySelector("input").value;
      // console.log(id);
      let movieHash = movieArray.find((movie) => {
        return movie.id == id;
      });
      // console.log(movieHash);
      div.style.backgroundImage = `url(${movieHash.url})`;
      div.style.backgroundSize = "cover";
    });
  }

  countMovies() {
    let selected = document.querySelectorAll(".hide-checkbox:checked");
    console.log(selected.length);
  }
}
