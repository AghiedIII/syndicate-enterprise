import { Controller, Get, Post, UseGuards, Logger } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ProjectsService } from './projects.service';

@Controller('api/v1/projects')
@UseGuards(AuthGuard('jwt'))
export class ProjectsController {
  private logger = new Logger(ProjectsController.name);

  constructor(private projectsService: ProjectsService) {}

  @Get()
  async listProjects() {
    this.logger.debug('Fetching projects list');
    return this.projectsService.findAll();
  }

  @Post()
  async createProject() {
    this.logger.debug('Creating new project');
    return { message: 'Project creation endpoint - under development' };
  }
}
