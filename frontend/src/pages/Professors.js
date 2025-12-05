import React, { useState } from "react";
import { Table, Form, Button } from "react-bootstrap";

const Professors = () => {
  const [professors, setProfessors] = useState([]);
  const [form, setForm] = useState({
    prof_id: "",
    prof_name: "",
    dept_id: "",
    experience: "",
  });

  const [editingId, setEditingId] = useState(null);

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSubmit = (e) => {
    e.preventDefault();

    if (editingId === null) {
      const newProf = {
        id: Date.now(),
        ...form,
      };
      setProfessors([...professors, newProf]);
    } else {
      const updatedList = professors.map((p) =>
        p.id === editingId ? { ...p, ...form } : p
      );
      setProfessors(updatedList);
      setEditingId(null);
    }

    setForm({ prof_id: "", prof_name: "", dept_id: "", experience: "" });
  };

  const handleEdit = (prof) => {
    setForm({
      prof_id: prof.prof_id,
      prof_name: prof.prof_name,
      dept_id: prof.dept_id,
      experience: prof.experience,
    });
    setEditingId(prof.id);
  };

  const handleDelete = (id) => {
    setProfessors(professors.filter((p) => p.id !== id));
  };

  return (
    <div>
      <h3>Professors Module</h3>

      {/* FORM */}
      <Form onSubmit={handleSubmit} className="mb-4">
        <Form.Group className="mb-2">
          <Form.Label>Professor ID</Form.Label>
          <Form.Control
            name="prof_id"
            value={form.prof_id}
            onChange={handleChange}
            required
          />
        </Form.Group>

        <Form.Group className="mb-2">
          <Form.Label>Professor Name</Form.Label>
          <Form.Control
            name="prof_name"
            value={form.prof_name}
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
          <Form.Label>Experience (years)</Form.Label>
          <Form.Control
            name="experience"
            value={form.experience}
            onChange={handleChange}
            required
          />
        </Form.Group>

        <Button type="submit" variant={editingId ? "warning" : "primary"}>
          {editingId ? "Update Professor" : "Add Professor"}
        </Button>
      </Form>

      {/* TABLE */}
      <Table striped bordered hover>
        <thead>
          <tr>
            <th>Professor ID</th>
            <th>Name</th>
            <th>Department ID</th>
            <th>Experience</th>
            <th>Actions</th>
          </tr>
        </thead>

        <tbody>
          {professors.length === 0 ? (
            <tr>
              <td colSpan="5" className="text-center">
                No professors added yet.
              </td>
            </tr>
          ) : (
            professors.map((p) => (
              <tr key={p.id}>
                <td>{p.prof_id}</td>
                <td>{p.prof_name}</td>
                <td>{p.dept_id}</td>
                <td>{p.experience}</td>
                <td>
                  <Button
                    variant="info"
                    size="sm"
                    className="me-2"
                    onClick={() => handleEdit(p)}
                  >
                    Edit
                  </Button>

                  <Button
                    variant="danger"
                    size="sm"
                    onClick={() => handleDelete(p.id)}
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

export default Professors;
