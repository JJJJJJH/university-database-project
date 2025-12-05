import React, { useState } from "react";
import { Table, Form, Button } from "react-bootstrap";

const Courses = () => {
  const [courses, setCourses] = useState([]);
  const [form, setForm] = useState({
    course_id: "",
    course_name: "",
    dept_id: "",
    credits: "",
  });

  const [editingId, setEditingId] = useState(null);

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSubmit = (e) => {
    e.preventDefault();

    if (editingId === null) {
      const newCourse = {
        id: Date.now(),
        ...form,
      };
      setCourses([...courses, newCourse]);
    } else {
      const updatedList = courses.map((c) =>
        c.id === editingId ? { ...c, ...form } : c
      );
      setCourses(updatedList);
      setEditingId(null);
    }

    setForm({
      course_id: "",
      course_name: "",
      dept_id: "",
      credits: "",
    });
  };

  const handleEdit = (course) => {
    setForm({
      course_id: course.course_id,
      course_name: course.course_name,
      dept_id: course.dept_id,
      credits: course.credits,
    });
    setEditingId(course.id);
  };

  const handleDelete = (id) => {
    setCourses(courses.filter((c) => c.id !== id));
  };

  return (
    <div>
      <h3>Courses Module</h3>

      {/* FORM */}
      <Form onSubmit={handleSubmit} className="mb-4">
        <Form.Group className="mb-2">
          <Form.Label>Course ID</Form.Label>
          <Form.Control
            name="course_id"
            value={form.course_id}
            onChange={handleChange}
            required
          />
        </Form.Group>

        <Form.Group className="mb-2">
          <Form.Label>Course Name</Form.Label>
          <Form.Control
            name="course_name"
            value={form.course_name}
            onChange={handleChange}
            required
          />
        </Form.Group>

        <Form.Group className="mb-2">
          <Form.Label>Department ID</Form.Label>
          <Form.Control
            name="dept_id"
            value={form.dept_id}
            onChange={handleChange}
            required
          />
        </Form.Group>

        <Form.Group className="mb-2">
          <Form.Label>Credits</Form.Label>
          <Form.Control
            name="credits"
            value={form.credits}
            onChange={handleChange}
            required
          />
        </Form.Group>

        <Button type="submit" variant={editingId ? "warning" : "primary"}>
          {editingId ? "Update Course" : "Add Course"}
        </Button>
      </Form>

      {/* TABLE */}
      <Table striped bordered hover>
        <thead>
          <tr>
            <th>Course ID</th>
            <th>Name</th>
            <th>Department ID</th>
            <th>Credits</th>
            <th>Actions</th>
          </tr>
        </thead>

        <tbody>
          {courses.length === 0 ? (
            <tr>
              <td colSpan="5" className="text-center">
                No courses added yet.
              </td>
            </tr>
          ) : (
            courses.map((c) => (
              <tr key={c.id}>
                <td>{c.course_id}</td>
                <td>{c.course_name}</td>
                <td>{c.dept_id}</td>
                <td>{c.credits}</td>
                <td>
                  <Button
                    variant="info"
                    size="sm"
                    className="me-2"
                    onClick={() => handleEdit(c)}
                  >
                    Edit
                  </Button>

                  <Button
                    variant="danger"
                    size="sm"
                    onClick={() => handleDelete(c.id)}
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

export default Courses;
