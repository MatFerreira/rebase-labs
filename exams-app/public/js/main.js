"use strict";

async function getExams() {
  const url = 'http://localhost:3000/tests';
  const response = await fetch(url);
  const exams = await response.json();
  return exams;
}

async function setExamsList() {
  const exams = await getExams();

  exams.forEach((exam) => {
    const examCard = buildExamCard(exam);
    document.querySelector('section#exam-list').appendChild(examCard);
  });
}

function buildExamCard(exam) {
  const examDiv = document.createElement('div');
  const examList = document.createElement('ul');

  const patientName = document.createElement('li');
  patientName.textContent = `Paciente: ${exam["patient_name"]}`;

  const doctorName = document.createElement('li');
  doctorName.textContent = `Médico: ${exam["doctor_name"]}`;

  const examType = document.createElement('li');
  examType.textContent = `Tipo do Exame: ${exam["exam_type"]}`;

  examList.append(patientName, doctorName, examType);
  examDiv.appendChild(examList);

  return examDiv;
}

setExamsList();
