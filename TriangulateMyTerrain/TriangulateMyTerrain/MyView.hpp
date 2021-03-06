#pragma once

#include <SceneModel/Context.hpp>
#include <tygra/WindowViewDelegate.hpp>
#include <tygra/FileHelper.hpp>
#include <tgl/tgl.h>
#include <glm/glm.hpp>
#include "Mesh.h"
#include "Quadtree.h"

class MyView : public tygra::WindowViewDelegate
{
public:

    MyView();

    ~MyView();

    void
    setScene(std::shared_ptr<const SceneModel::Context> scene);

    void
    toggleShading();

private:

    void
    windowViewWillStart(std::shared_ptr<tygra::Window> window) override;

    void
    windowViewDidReset(std::shared_ptr<tygra::Window> window,
                       int width,
                       int height) override;

    void
    windowViewDidStop(std::shared_ptr<tygra::Window> window) override;

    void
    windowViewRender(std::shared_ptr<tygra::Window> window) override;

	void ApplyHeightImage(tygra::Image image, float outputScale, Mesh& mesh);

	void ApplyBezierSurface(std::vector<Array2d<glm::vec3, 4, 4>> bezier_patches, size_t number_of_patches, Mesh& mesh);

	void ExtractFrustum();
private:

    std::shared_ptr<const SceneModel::Context> scene_;

    GLuint terrain_sp_{ 0 };
    GLuint shapes_sp_{ 0 };

    bool shade_normals_{ false };

    struct MeshGL
    {
		GLuint first_element_index{ 0 };
		GLuint element_count{ 0 };
		GLuint first_vertex_index{ 0 };
    };
    MeshGL terrain_mesh_;

    enum
    {
        kVertexPosition = 0,
        kVertexNormal = 1,
    };

	GLuint cube_vao_{ 0 };
	GLuint cube_vbo_{ 0 };


	GLuint vertex_vbo{ 0 };
	GLuint element_vbo{ 0 }; // VertexBufferObject for the elements (indices)
	GLuint vao{ 0 }; // VertexArrayObject for the shape's vertex array settings

	int screenWidth, screenHeight;
	FreddieBabord::Quadtree* tree;
};
