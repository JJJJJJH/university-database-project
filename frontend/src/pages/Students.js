import React, { useState } from "react";
import { Table, Form, Button } from "react-bootstrap";

const Students = () => {
  const [students, setStudents] = useState([]);
  const [form, setForm] = useState({
    student_id: "",
    name: "",
    year: "",
    major: ""
  });

  const [editingId, setEditingId] = useState(null);

  // Handle form input change
  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  // Insert or Update student
  const handleSubmit = (e) => {
    e.preventDefault();

    if (editingId === null) {
      // INSERT
      const newStudent = {
        id: Date.now(),
        ...form,
      };
      setStudents([...students, newStudent]);
    } else {
      // UPDATE
      const updatedList = students.map((s) =>
        s.id === editingId ? { ...s, ...form } : s
      );
      setStudents(updatedList);
      setEditingId(null);
    }

    // Clear form
    setForm({ student_id: "", name: "", year: "", major: "" });
  };

  // Edit student
  const handleEdit = (student) => {
    setForm({
      student_id: student.student_id,
      name: student.name,
      year: student.year,
      major: student.major,
    });
    setEditingId(student.id);
  };

  // Delete student
  const handleDelete = (id) => {
    setStudents(students.filter((s) => s.id !== id));
  };

  return (
    <div>
      <h3>Students Module</h3>

      {/* FORM */}
      <Form onSubmit={handleSubmit} className="mb-4">
        <Form.Group className="mb-2">
          <Form.Label>Student ID</Form.Label>
          <Form.Control
            name="student_id"
            value={form.student_id}
            onChange={handleChange}
            required
          />
        </Form.Group>

        <Form.Group className="mb-2">
          <Form.Label>Name</Form.Label>
          <Form.Control
            name="name"
            value={form.name}
            onChange={handleChange}
            required
          />
        </Form.Group>

        <Form.Group className="mb-2">
          <Form.Label>Year</Form.Label>
          <Form.Control
            name="year"
            value={form.year}
            onChange={handleChange}
            required
          />
        </Form.Group>

        <Form.Group className="mb-2">
          <Form.Label>Major</Form.Label>
          <Form.Control
            name="major"
            value={form.major}
            onChange={handleChange}
            required
          />
        </Form.Group>

        <Button type="submit" variant={editingId ? "warning" : "primary"}>
          {editingId ? "Update Student" : "Add Student"}
        </Button>
      </Form>

      {/* TABLE */}
      <Table striped bordered hover>
        <thead>
          <tr>
            <th>Student ID</th>
            <th>Name</th>
            <th>Year</th>
            <th>Major</th>
            <th>Actions</th>
          </tr>
        </thead>

        <tbody>
          {students.length === 0 ? (
            <tr>
              <td colSpan="5" className="text-center">
                No students added yet.
              </td>
            </tr>
          ) : (
            students.map((s) => (
              <tr key={s.id}>
                <td>{s.student_id}</td>
                <td>{s.name}</td>
                <td>{s.year}</td>
                <td>{s.major}</td>
                <td>
                  <Button
                    variant="info"
                    size="sm"
                    className="me-2"
                    onClick={() => handleEdit(s)}
                  >
                    Edit
                  </Button>

                  <Button
                    variant="danger"
                    size="sm"
                    onClick={() => handleDelete(s.id)}
                  >
                    Delete
                  </Button>
                </td>
              </tr>
            ))
          )}
        </tbody>
      </Table>
    </div>
  );
};

export default Students;
