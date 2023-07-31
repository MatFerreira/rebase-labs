"use strict";

let hasNext = true;
let pageNumber = 1;
const limit = 5;

async function getPage(pageNumber, limit) {
  const url = `http://localhost:3000/exams?page=${pageNumber}&limit=${limit}`;
  const response = await fetch(url);
  const page = await response.json();
  return page;
}

async function loadPageData() {
  const page = await getPage(pageNumber, limit);
  const exams = page.data

  exams.forEach((exam) => {
    const examCard = buildExamCard(exam);
    document.querySelector('section#exam-list').appendChild(examCard);
  });

  pageNumber++;
  hasNext = exams["has_next"];
}

function buildExamCard(exam) {
  const examCard = document.createElement('div');
  examCard.innerHTML = `
    <h3>${exam["exam_result_token"]}</h3>
    <ul>
      <li>Paciente: ${exam["name"]}</li>
      <li>Médico: ${exam["doctor"]["name"]}</li>
      <li>Data do Exame: ${exam["exam_date"]}</li>
    </ul>
  `;

  const testsData = exam.tests.map((t) => `
    <tr>
      <td>${t["exam_type"]}</td>
      <td>${t["exam_type_limits"]}</td>
      <td>${t["exam_type_result"]}</td>
    </tr>
  `).join('');

  const testsTable = `
    <table>
      <tr>
        <th>Tipo</th>
        <th>Limites</th>
        <th>Resultado</th>
      </tr>
      ${testsData}
    </table>
  `;

  examCard.innerHTML += testsTable

  return examCard;
}

loadPageData()
window.addEventListener('scroll', () => {
  if (document.documentElement.scrollHeight - window.innerHeight <= window.scrollY) {
    loadPageData();
  }
});
