import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class ProjectsService {
  private logger = new Logger(ProjectsService.name);

  async findAll() {
    this.logger.debug('Querying all projects');
    return {
      success: true,
      data: {
        projects: [],
        total: 0,
      },
    };
  }

  async findById(id: string) {
    this.logger.debug(`Fetching project: ${id}`);
    return null;
  }

  async create(projectData: any) {
    this.logger.debug(`Creating project: ${projectData.project_id}`);
    return null;
  }
}
